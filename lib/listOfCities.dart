import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/Models/citiesList.dart';
import 'package:weather_app/Models/city.dart';
import 'package:weather_app/citiesTile.dart';
import 'package:weather_app/weather_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:weather_app/Models/weather_api_model.dart';

class ListOfCities extends StatefulWidget {
  const ListOfCities({super.key});

  @override
  State<ListOfCities> createState() => _ListOfCitiesState();
}

class _ListOfCitiesState extends State<ListOfCities> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _addController = TextEditingController();

  void _searchCity(BuildContext context) {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter a city name'),
      ));
      return;
    }
    _validateAndNavigate(query, context);
  }

  Future<void> _validateAndNavigate(String city, BuildContext context) async {
    final encoded = Uri.encodeComponent(city);
    const key = api_key;
    final url = Uri.parse(
        'https://api.weatherapi.com/v1/current.json?key=$key&q=$encoded&aqi=no');
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final jsonBody = json.decode(res.body) as Map<String, dynamic>;
        final data = WeatherData.fromJson(jsonBody);
        if (!mounted) return;
        // Debug log to show the API response in the console (trimmed)
        try {
          final trimmed = res.body.length > 200
              ? res.body.substring(0, 200) + '...'
              : res.body;
          // ignore: avoid_print
          print('Search API success for "$city": ${res.statusCode} - $trimmed');
        } catch (_) {}
        navigator.push(MaterialPageRoute(builder: (context) {
          return WeatherPage(cityName: city, initialData: data);
        }));
      } else if (res.statusCode == 401) {
        if (!mounted) return;
        messenger.showSnackBar(const SnackBar(
          content: Text(
              'Unauthorized (401): invalid API key. Update lib/Models/city.dart'),
        ));
      } else if (res.statusCode == 400 ||
          res.statusCode == 403 ||
          res.statusCode == 404) {
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(
          content: Text(
              'City not found or invalid request (code ${res.statusCode})'),
        ));
      } else {
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(
          content: Text('Error fetching weather (code ${res.statusCode})'),
        ));
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(
        content: Text('Network error while searching for city'),
      ));
    }
  }

  Future<void> _validateAndAdd(String city, BuildContext context) async {
    final trimmedCity = city.trim();
    if (trimmedCity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('City name cannot be empty'),
      ));
      return;
    }

    // avoid adding duplicates
    final existing = Provider.of<CitiesList>(context, listen: false)
        .cityList
        .any((c) => c.cityName.toLowerCase() == trimmedCity.toLowerCase());
    if (existing) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('City already in favorites'),
      ));
      return;
    }

    final encoded = Uri.encodeComponent(trimmedCity);
    const key = api_key;
    final url = Uri.parse('https://api.weatherapi.com/v1/current.json?key=$key&q=$encoded&aqi=no');
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        // valid city, add to provider
        Provider.of<CitiesList>(context, listen: false)
            .addItemToCart(Cities(cityName: trimmedCity));
        if (!mounted) return;
        messenger.showSnackBar(const SnackBar(
          content: Text('City added to favorites'),
        ));
        navigator.pop(); // close dialog
      } else if (res.statusCode == 401) {
        if (!mounted) return;
        messenger.showSnackBar(const SnackBar(
            content: Text('Unauthorized (401): invalid API key')));
      } else if (res.statusCode == 400 ||
          res.statusCode == 403 ||
          res.statusCode == 404) {
        if (!mounted) return;
        messenger.showSnackBar(const SnackBar(
            content: Text('City not found or invalid request')));
      } else {
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(
            content: Text('Error fetching weather (code ${res.statusCode})')));
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(
        content: Text('Network error while searching for city'),
      ));
    }
  }

  void _showAddCityDialog(BuildContext context) {
    _addController.clear();
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Add favorite city'),
            content: TextField(
              controller: _addController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'e.g. London'),
              onSubmitted: (value) => _validateAndAdd(value, context),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () => _validateAndAdd(_addController.text, context),
                  child: const Text('Add'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CitiesList>(
      builder: (context, value, child) => Scaffold(
        backgroundColor: Colors.blue[300],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Blue Skies', style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(Icons.search, color: Colors.blue),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _searchCity(context),
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search city...'),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _searchController.clear(),
                        icon: const Icon(Icons.clear, color: Colors.blue),
                      ),
                      IconButton(
                        onPressed: () => _searchCity(context),
                        icon: const Icon(Icons.arrow_circle_right, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                const Text(
                  "Favorites",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap a city to view live weather. Use + to add favorites.',
                  style: TextStyle(color: const Color.fromRGBO(255, 255, 255, 0.9)),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: ListView.builder(
                        itemCount: value.cityList.length,
                        itemBuilder: (context, index) {
                          Cities eachCity = value.cityList[index];
                          return CitiesTile(cityName: eachCity.cityName);
                        }))
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddCityDialog(context),
          backgroundColor: Colors.blue[50],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
