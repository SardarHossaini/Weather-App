import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:weather_app/Models/weather_api_model.dart';
import 'package:weather_app/Models/city.dart';

class WeatherPage extends StatefulWidget {
  final String cityName;
  final WeatherData? initialData;
  const WeatherPage({super.key, required this.cityName, this.initialData});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  WeatherData? _weather;
  String? _errorMessage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _weather = widget.initialData;
      _loading = false;
    } else {
      _fetchWeather();
    }
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final city = Uri.encodeComponent(widget.cityName);
    const key = api_key;
    final url = Uri.parse(
        'https://api.weatherapi.com/v1/current.json?key=$key&q=$city&aqi=no');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final jsonBody = json.decode(res.body) as Map<String, dynamic>;
        final data = WeatherData.fromJson(jsonBody);
        setState(() {
          _weather = data;
          _errorMessage = null;
          _loading = false;
        });
      } else if (res.statusCode == 401) {
        setState(() {
          _errorMessage =
              'Unauthorized (401): invalid API key. Please update api_key in lib/Models/city.dart';
          _loading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Error fetching weather (code ${res.statusCode})';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error while fetching weather';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[300],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _fetchWeather,
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      );
    }
    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _locationHeader(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.08,
          ),
          _dateTimeInfo(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.05,
          ),
          _weatherIcon(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.02,
          ),
          _currentTump(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.02,
          ),
          _extraInfo(),
        ],
      ),
    );
  }

  Widget _locationHeader() {
    return Text(
      _weather?.locationName ?? "",
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
    );
  }

  Widget _dateTimeInfo() {
    DateTime now = _weather!.lastUpdated;
    return Column(
      children: [
        Text(
          DateFormat('h:mm a').format(now),
          style: const TextStyle(fontSize: 28),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat('EEEE').format(now),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              "  ${DateFormat('d.m.y').format(now)}",
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ],
        )
      ],
    );
  }

  Widget getWeatherIcon(String? description) {
    switch (description) {
      case "clear sky":
        return SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.3,
          child: Lottie.asset('assets/animations/suny.json'),
        );
      case "few clouds" ||
            "scattered clouds" ||
            "broken clouds" ||
            "overcast clouds":
        return SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.3,
          child: Lottie.asset('assets/animations/sun_cloud.json'),
        );
      case "light rain" ||
            "moderate rain" ||
            "heavy intensity rain" ||
            "very heavy rain" ||
            "extreme rain" ||
            "freezing rain" ||
            "light intensity shower rain" ||
            "shower rain" ||
            "heavy intensity shower rain" ||
            "ragged shower rain":
        return SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.3,
          child: Lottie.asset('assets/animations/rany.json'),
        );
      case "light snow" ||
            "snow" ||
            "heavy snow" ||
            "sleet" ||
            "light shower sleet" ||
            "shower sleet" ||
            "light rain and snow" ||
            "rain and snow" ||
            "light shower snow" ||
            "shower snow" ||
            "heavy shower snow":
        return SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.3,
          child: Lottie.asset('assets/animations/snowy.json'),
        );
      case "thunderstorm with light rain" ||
            "thunderstorm with rain" ||
            "thunderstorm with heavy rain" ||
            "light thunderstorm" ||
            "thunderstorm" ||
            "heavy thunderstorm" ||
            "ragged thunderstorm" ||
            "thunderstorm with light drizzle" ||
            "thunderstorm with drizzle" ||
            "thunderstorm with heavy drizzl":
        return SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.3,
          child: Lottie.asset('assets/animations/stormy.json'),
        );
      default:
        return const Icon(Icons.help_outline, color: Colors.black45);
    }
  }

  Widget _weatherIcon() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        getWeatherIcon(_weather?.conditionText),
        Text(_weather?.conditionText ?? ""),
      ],
    );
  }

  Widget _currentTump() {
    return Text(
      _weather == null ? '-' : "${_weather!.tempC.toStringAsFixed(0)}° C",
      style: const TextStyle(fontSize: 20),
    );
  }

  Widget _extraInfo() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.15,
      width: MediaQuery.sizeOf(context).width * 0.8,
      decoration: BoxDecoration(
          color: Colors.blue, borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Feels: ${_weather?.feelsLikeC != null ? _weather!.feelsLikeC!.toStringAsFixed(0) : '-'}° C",
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              Text(
                "Precip: ${_weather?.precipMm != null ? _weather!.precipMm!.toStringAsFixed(1) : '-'} mm",
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Wind: ${_weather?.windKph != null ? _weather!.windKph!.toStringAsFixed(0) : '-'} kph",
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              Text(
                "Humidity: ${_weather?.humidity ?? '-'}%",
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
