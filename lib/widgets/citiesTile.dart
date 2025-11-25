import 'package:flutter/material.dart';
import 'package:weather_app/widgets/weather_page.dart';
import 'package:weather_app/Models/city.dart' hide api_key;
import 'package:weather_app/Models/weather_api_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CitiesTile extends StatelessWidget {
  final String cityName;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final double temperature;
  final String weatherCondition;
  final String weatherIcon;
  final bool isCurrentLocation;
  final bool isFavorite;

  const CitiesTile({
    super.key,
    required this.cityName,
    this.onTap,
    this.onFavoriteTap,
    required this.temperature,
    required this.weatherCondition,
    required this.weatherIcon,
    this.isCurrentLocation = false,
    this.isFavorite = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap ?? () => _navigateToWeatherPage(context),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1F3A5F).withOpacity(0.8),
                const Color(0xFF4A6FA5).withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background pattern
              _buildBackgroundPattern(),

              // Main content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Location Icon
                    _buildLocationIcon(),
                    const SizedBox(width: 16),

                    // City Info - Expanded to take available space
                    Expanded(
                      child: _buildCityInfo(),
                    ),

                    // Temperature and Weather Icon - Fixed width container
                    Container(
                      width: 80,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Temperature
                          Text(
                            '${temperature.toStringAsFixed(0)}°',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w300,
                            ),
                          ),

                          // Weather Icon
                          Image.network(
                            'https:$weatherIcon',
                            width: 26,
                            height: 26,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildWeatherIcon(weatherCondition);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Favorite Button
              _buildFavoriteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToWeatherPage(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final encoded = Uri.encodeComponent(cityName);
    final key = api_key;
    final url = Uri.parse(
        'https://api.weatherapi.com/v1/current.json?key=$key&q=$encoded&aqi=no');

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
        messenger.showSnackBar(const SnackBar(
            content: Text('Unauthorized (401): invalid API key')));
      } else {
        messenger.showSnackBar(SnackBar(
            content: Text('Error fetching weather (code ${res.statusCode})')));
      }
    } catch (e) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Network error while fetching weather')));
    }
  }

  Widget _buildLocationIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Icon(
        isCurrentLocation
            ? Icons.my_location_rounded
            : Icons.location_on_rounded,
        color: Colors.white.withOpacity(0.8),
        size: 24,
      ),
    );
  }

  Widget _buildCityInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(
              cityName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            if (isCurrentLocation) ..._buildCurrentLocationBadge(),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          weatherCondition,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  List<Widget> _buildCurrentLocationBadge() {
    return [
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF4A6FA5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          "Current",
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ];
  }

  Widget _buildFavoriteButton() {
    return Positioned(
      top: 12,
      left: 12,
      child: GestureDetector(
        onTap: onFavoriteTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.favorite_rounded,
            color: isFavorite
                ? const Color(0xFFFF6B6B)
                : Colors.white.withOpacity(0.3),
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned(
      right: -20,
      top: -20,
      child: Opacity(
        opacity: 0.05,
        child: Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Color(0xFF4A6FA5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherIcon(String condition) {
    IconData icon;
    Color color;

    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        icon = Icons.wb_sunny_rounded;
        color = const Color(0xFFFFD700);
        break;
      case 'partly cloudy':
      case 'cloudy':
      case 'overcast':
        icon = Icons.cloud_rounded;
        color = Colors.white;
        break;
      case 'rainy':
      case 'rain':
      case 'light rain':
      case 'moderate rain':
        icon = Icons.beach_access_rounded;
        color = const Color(0xFF4A90E2);
        break;
      case 'snowy':
      case 'snow':
      case 'light snow':
        icon = Icons.ac_unit_rounded;
        color = Colors.white;
        break;
      default:
        icon = Icons.wb_sunny_rounded;
        color = const Color(0xFFFFD700);
    }

    return Icon(
      icon,
      color: color,
      size: 30,
    );
  }
}
