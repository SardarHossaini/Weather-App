
import 'package:flutter/material.dart';
import 'package:weather_app/weather_page.dart';
import 'package:weather_app/Models/city.dart';
import 'package:weather_app/Models/weather_api_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CitiesTile extends StatelessWidget {
  final String cityName;
  const CitiesTile({super.key, required this.cityName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.blue[50],
      ),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        onTap: () async {
          final messenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);
          final encoded = Uri.encodeComponent(cityName);
          const key = api_key;
          final url = Uri.parse('https://api.weatherapi.com/v1/current.json?key=$key&q=$encoded&aqi=no');
          try {
            final res = await http.get(url);
            if (res.statusCode == 200) {
              final jsonBody = json.decode(res.body) as Map<String, dynamic>;
              final data = WeatherData.fromJson(jsonBody);
              if (!navigator.mounted) return;
              navigator.push(MaterialPageRoute(builder: (context) {
                return WeatherPage(cityName: cityName, initialData: data);
              }));
            } else if (res.statusCode == 401) {
              messenger.showSnackBar(const SnackBar(content: Text('Unauthorized (401): invalid API key')));
            } else {
              messenger.showSnackBar(SnackBar(content: Text('Error fetching weather (code ${res.statusCode})')));
            }
          } catch (e) {
            messenger.showSnackBar(const SnackBar(content: Text('Network error while fetching weather')));
          }
        },
        iconColor: Colors.blue,
        title: Text(cityName),
        leading: const Icon(Icons.info),
        trailing: const Icon(Icons.arrow_circle_right),
      ),
    );
  }
}
