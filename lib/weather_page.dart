import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/weather_model.dart';
import 'package:weather_app/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService =
      WeatherService(apiKey: '863d94389b273e93cd43606666c5f057');
  Weather? _weather;

  fetchWeather() async {
    String cityName = await _weatherService.getCurrentCity();

    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch ($e) {
      print($e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset('assets/animations/weather.json'),
      ),
    );
  }
}
