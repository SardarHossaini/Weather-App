import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/weather_model.dart';
import 'package:weather_app/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // final _weatherService =
  //     WeatherService(apiKey: '1858d0131bbbb81a86dde58a43529d3e');
  // Weather? _weather;

  // fetchWeather() async {
  //   String cityName = await _weatherService.getCurrentCity();

  //   try {
  //     final weather = await _weatherService.getWeather(cityName);
  //     setState(() {
  //       _weather = weather;
  //     });
  //   } catch ($e) {
  //     return $e;
  //   }
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   fetchWeather();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          Lottie.asset('assets/animations/weather.json'),
          // Text(_weather?.cityName ?? ""),
          // Text("${_weather?.tempretuer.round()} C")
        ],
      )),
    );
  }
}
