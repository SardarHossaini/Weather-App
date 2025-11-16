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
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchWeather,
          ),
        ],
      ),
      body: _buildUI(),
    );
  }

  Color _getBackgroundColor() {
    if (_weather == null) return Colors.blue[700]!;

    final condition = _weather!.conditionText?.toLowerCase() ?? '';
    final isDay = _weather?.isDay ?? 1;

    if (condition.contains('sunny') || condition.contains('clear')) {
      return isDay == 1 ? const Color(0xFF47AB2F) : const Color(0xFF1A237E);
    } else if (condition.contains('cloud')) {
      return isDay == 1 ? const Color(0xFF54717A) : const Color(0xFF37474F);
    } else if (condition.contains('rain')) {
      return const Color(0xFF57575D);
    } else if (condition.contains('snow')) {
      return const Color(0xFF4A6572);
    } else if (condition.contains('thunder')) {
      return const Color(0xFF303030);
    }

    return Colors.blue[700]!;
  }

  Widget _buildUI() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading weather data...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 20),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchWeather,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _getBackgroundColor(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              )
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            // Location and Date Section
            _locationDateSection(),

            // Temperature and Weather Icon Section
            _temperatureSection(),

            // Weather Details Section
            _weatherDetailsSection(),

            // Additional Info Cards
            _additionalInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _locationDateSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                color: Colors.white.withOpacity(0.9),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _weather?.locationName ?? "Unknown Location",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('EEEE, MMMM d').format(_weather!.lastUpdated),
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            DateFormat('h:mm a').format(_weather!.lastUpdated),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _temperatureSection() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Weather Icon from API
          if (_weather?.conditionIcon != null)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Image.network(
                'https:${_weather!.conditionIcon!}',
                width: 80,
                height: 80,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.help_outline, color: Colors.white, size: 40),
              ),
            )
          else
            _fallbackWeatherIcon(),

          const SizedBox(height: 16),

          // Temperature
          Text(
            _weather == null ? '-' : "${_weather!.tempC.toStringAsFixed(0)}°",
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: -2,
            ),
          ),

          // Weather Condition
          Text(
            _weather?.conditionText ?? "Unknown",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          // Feels Like
          Text(
            "Feels like ${_weather?.feelsLikeC != null ? _weather!.feelsLikeC!.toStringAsFixed(0) : '-'}°",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackWeatherIcon() {
    final condition = _weather?.conditionText?.toLowerCase() ?? '';

    if (condition.contains('clear') || condition.contains('sunny')) {
      return Lottie.asset(
        'assets/animations/suny.json',
        width: 120,
        height: 120,
      );
    } else if (condition.contains('cloud')) {
      return Lottie.asset(
        'assets/animations/sun_cloud.json',
        width: 120,
        height: 120,
      );
    } else if (condition.contains('rain')) {
      return Lottie.asset(
        'assets/animations/rany.json',
        width: 120,
        height: 120,
      );
    } else if (condition.contains('snow')) {
      return Lottie.asset(
        'assets/animations/snowy.json',
        width: 120,
        height: 120,
      );
    } else if (condition.contains('thunder')) {
      return Lottie.asset(
        'assets/animations/stormy.json',
        width: 120,
        height: 120,
      );
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.help_outline,
        color: Colors.white,
        size: 40,
      ),
    );
  }

  Widget _weatherDetailsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _detailItem(
            icon: Icons.air,
            value:
                '${_weather?.windKph != null ? _weather!.windKph!.toStringAsFixed(0) : '-'} km/h',
            label: 'Wind',
          ),
          _detailItem(
            icon: Icons.water_drop,
            value: '${_weather?.humidity ?? '-'}%',
            label: 'Humidity',
          ),
          _detailItem(
            icon: Icons.visibility,
            value:
                '${_weather?.visKm != null ? _weather!.visKm!.toStringAsFixed(1) : '-'} km',
            label: 'Visibility',
          ),
        ],
      ),
    );
  }

  Widget _detailItem(
      {required IconData icon, required String value, required String label}) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _additionalInfoSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: _infoCard(
              title: 'Precipitation',
              value:
                  '${_weather?.precipMm != null ? _weather!.precipMm!.toStringAsFixed(1) : '0.0'} mm',
              icon: Icons.cloudy_snowing,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _infoCard(
              title: 'Pressure',
              value:
                  '${_weather?.pressureMb != null ? _weather!.pressureMb!.toStringAsFixed(0) : '-'} hPa',
              icon: Icons.speed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(
      {required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
