import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset('assets/animations/weather.json'),
      ),
    );
  }
}
