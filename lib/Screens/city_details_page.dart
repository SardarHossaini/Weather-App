import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../models/citiesList.dart';
import '../services/weather_service.dart';

class CityDetailsPage extends StatefulWidget {
  final String cityName;
  final bool isFavorite;
  final Map<String, dynamic>? weatherData;

  const CityDetailsPage({
    super.key,
    required this.cityName,
    required this.isFavorite,
    this.weatherData,
  });

  @override
  State<CityDetailsPage> createState() => _CityDetailsPageState();
}

class _CityDetailsPageState extends State<CityDetailsPage> {
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    // If weatherData is provided, use it directly
    if (widget.weatherData != null) {
      setState(() {
        _weatherData = widget.weatherData;
        _isLoading = false;
      });
      return;
    }

    // Otherwise fetch from API
    final data = await WeatherService.fetchWeatherData(widget.cityName);
    setState(() {
      _weatherData = data;
      _isLoading = false;
    });
  }

  void _toggleFavorite() {
    final citiesList = Provider.of<CitiesList>(context, listen: false);
    if (widget.isFavorite) {
      citiesList.removeCity(widget.cityName);
    } else {
      citiesList.addCity(widget.cityName);
    }
    Navigator.pop(context);
  }

  // Map weather condition to Lottie animation
  String _getLottieAsset(String weatherCondition) {
    final condition = weatherCondition.toLowerCase();

    if (condition.contains('sunny') || condition.contains('clear')) {
      return 'assets/lottie/sunny.json';
    } else if (condition.contains('partly cloudy')) {
      return 'assets/lottie/cloudy.json';
    } else if (condition.contains('cloud')) {
      return 'assets/lottie/cloudy.json';
    } else if (condition.contains('rain') || condition.contains('drizzle')) {
      return 'assets/lottie/rany.json';
    } else if (condition.contains('snow') || condition.contains('sleet')) {
      return 'assets/lottie/snowy.json';
    } else if (condition.contains('thunder') || condition.contains('storm')) {
      return 'assets/lottie/sun_storm.json';
    } else if (condition.contains('fog') ||
        condition.contains('mist') ||
        condition.contains('haze')) {
      return 'assets/lottie/stormy.json';
    } else if (condition.contains('wind')) {
      return 'assets/lottie/sun_ran.json';
    } else {
      return 'assets/lottie/cloudy.json'; // Default fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1C2E),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F1C2E),
              Color(0xFF1F3A5F),
              Color(0xFF0F1C2E),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white.withOpacity(0.8),
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            widget.cityName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          onPressed: _toggleFavorite,
          icon: Icon(
            Icons.favorite_rounded,
            color: widget.isFavorite
                ? const Color(0xFFFF6B6B)
                : Colors.white.withOpacity(0.3),
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    } else if (_weatherData != null) {
      return _buildWeatherContent();
    } else {
      return _buildErrorState();
    }
  }

  Widget _buildLoadingState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/loading.json', // You can create a loading animation
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 20),
            Text(
              "Loading weather data...",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/error.json', // Error animation
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 16),
            const Text(
              "Failed to load weather data",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchWeatherData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A6FA5),
                foregroundColor: Colors.white,
              ),
              child: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    final condition =
        _weatherData!['current']['condition']['text'] ?? 'Unknown';
    final lottieAsset = _getLottieAsset(condition);

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Temperature Card with Lottie Animation
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1F3A5F).withOpacity(0.8),
                    const Color(0xFF4A6FA5).withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '${_weatherData!['current']['temp_c'].toStringAsFixed(0)}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lottie Animation instead of static image
                  Lottie.asset(
                    lottieAsset,
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 8),
                  Text(
                    condition,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Additional Details
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Feels Like',
                      '${_weatherData!['current']['feelslike_c']}°'),
                  _buildDetailRow(
                      'Humidity', '${_weatherData!['current']['humidity']}%'),
                  _buildDetailRow('Wind Speed',
                      '${_weatherData!['current']['wind_kph']} km/h'),
                  _buildDetailRow('Pressure',
                      '${_weatherData!['current']['pressure_mb']} mb'),
                  _buildDetailRow(
                      'Visibility', '${_weatherData!['current']['vis_km']} km'),
                  _buildDetailRow(
                      'UV Index', '${_weatherData!['current']['uv']}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
