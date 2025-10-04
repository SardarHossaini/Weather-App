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
        // successful search — navigate with pre-fetched data
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
    final url = Uri.parse(
        'https://api.weatherapi.com/v1/current.json?key=$key&q=$encoded&aqi=no');
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
        messenger.showSnackBar(
            const SnackBar(content: Text('City not found or invalid request')));
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
                  onPressed: () =>
                      _validateAndAdd(_addController.text, context),
                  child: const Text('Add'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CitiesList>(
      builder: (context, value, child) => Scaffold(
        backgroundColor: Colors.blue[700],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wb_sunny, color: Colors.white, size: 28),
              SizedBox(width: 8),
              Text(
                'Blue Skies',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 16, right: 8),
                        child: Icon(Icons.search, color: Colors.blue, size: 24),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _searchCity(context),
                          style: const TextStyle(fontSize: 16),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search for a city...',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          onPressed: () => _searchController.clear(),
                          icon: const Icon(Icons.clear,
                              color: Colors.grey, size: 20),
                          splashRadius: 20,
                        ),
                      Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => _searchCity(context),
                          icon: const Icon(Icons.search,
                              color: Colors.white, size: 20),
                          splashRadius: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Header Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.favorite,
                            color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          "Favorite Cities",
                          style: TextStyle(
                            fontSize: 26,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${value.cityList.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap a city to view live weather. Use the + button to add more favorites.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Cities List
                Expanded(
                  child: value.cityList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_city,
                                size: 64,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No favorite cities yet',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap the + button to add your first city',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: ListView.builder(
                              itemCount: value.cityList.length,
                              itemBuilder: (context, index) {
                                Cities eachCity = value.cityList[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child:
                                      CitiesTile(cityName: eachCity.cityName),
                                );
                              },
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: FloatingActionButton(
            onPressed: () => _showAddCityDialog(context),
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue[700],
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ),
    );
  }
}
