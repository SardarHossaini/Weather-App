import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:weather/weather.dart';
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

  final WeatherFactory _wf = WeatherFactory(api_key);
  Weather? _weather;

  @override
  void initState() {
    super.initState();
    _wf.currentWeatherByCityName("Kabul").then((w) => {
          setState(() {
            _weather = w;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    if (_weather == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [],
      ),
    );
  }
}
