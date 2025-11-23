import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/citiesList.dart';
import '../services/weather_service.dart';

class CityDetailsPage extends StatefulWidget {
  final String cityName;
  final bool isFavorite;

  const CityDetailsPage({
    super.key,
    required this.cityName,
    required this.isFavorite,
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
        child: CircularProgressIndicator(
          color: Colors.white.withOpacity(0.7),
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
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 64,
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
              child: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildTemperatureCard(),
            const SizedBox(height: 24),
            _buildAdditionalDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureCard() {
    return Container(
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
          Image.network(
            'https:${_weatherData!['current']['condition']['icon']}',
            width: 64,
            height: 64,
          ),
          const SizedBox(height: 8),
          Text(
            _weatherData!['current']['condition']['text'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetails() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildDetailRow(
              'Feels Like', '${_weatherData!['current']['feelslike_c']}°'),
          _buildDetailRow(
              'Humidity', '${_weatherData!['current']['humidity']}%'),
          _buildDetailRow(
              'Wind Speed', '${_weatherData!['current']['wind_kph']} km/h'),
          _buildDetailRow(
              'Pressure', '${_weatherData!['current']['pressure_mb']} mb'),
        ],
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
