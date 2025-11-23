import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = '0380d0e84f324486aac191450251611';
  static const String _baseUrl = 'http://api.weatherapi.com/v1/current.json';

  static Future<Map<String, dynamic>?> fetchWeatherData(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?key=$_apiKey&q=$cityName&aqi=no'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching weather data for $cityName: $e');
      return null;
    }
  }

  static Map<String, dynamic> getDefaultWeatherData() {
    return {
      'temp': 20.0,
      'condition': 'Sunny',
      'icon': '//cdn.weatherapi.com/weather/64x64/day/113.png',
    };
  }
}
