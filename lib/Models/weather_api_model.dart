// ignore_for_file: file_names

import 'dart:convert';

const String api_key = '0380d0e84f324486aac191450251611';

class WeatherData {
  final String locationName;
  final DateTime lastUpdated;
  final String conditionText;
  final String conditionIcon;
  final double tempC;
  final double tempF;
  final double windKph;
  final int humidity;
  final double feelsLikeC;
  final double precipMm;
  final double pressureMb;
  final double visKm;
  final int isDay;

  WeatherData({
    required this.locationName,
    required this.lastUpdated,
    required this.conditionText,
    required this.conditionIcon,
    required this.tempC,
    required this.tempF,
    required this.windKph,
    required this.humidity,
    required this.feelsLikeC,
    required this.precipMm,
    required this.pressureMb,
    required this.visKm,
    required this.isDay,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final location = json['location'] ?? <String, dynamic>{};
    final current = json['current'] ?? <String, dynamic>{};
    final condition = current['condition'] ?? <String, dynamic>{};

    // Parse last_updated date safely
    DateTime parsedDate;
    try {
      final lastUpdatedStr = current['last_updated']?.toString() ?? '';
      if (lastUpdatedStr.isNotEmpty) {
        parsedDate = DateTime.parse(lastUpdatedStr.replaceAll(' ', 'T'));
      } else {
        parsedDate = DateTime.now();
      }
    } catch (_) {
      parsedDate = DateTime.now();
    }

    // Safe parsing with null checks
    return WeatherData(
      locationName: _getString(location, 'name', 'Unknown City'),
      lastUpdated: parsedDate,
      conditionText: _getString(condition, 'text', 'Unknown'),
      conditionIcon: _getString(condition, 'icon', ''),
      tempC: _getDouble(current, 'temp_c', 0.0),
      tempF: _getDouble(current, 'temp_f', 0.0),
      windKph: _getDouble(current, 'wind_kph', 0.0),
      humidity: _getInt(current, 'humidity', 0),
      feelsLikeC: _getDouble(current, 'feelslike_c', 0.0),
      precipMm: _getDouble(current, 'precip_mm', 0.0),
      pressureMb: _getDouble(current, 'pressure_mb', 0.0),
      visKm: _getDouble(current, 'vis_km', 0.0),
      isDay: _getInt(current, 'is_day', 1),
    );
  }

  // Helper methods for safe data extraction
  static String _getString(
      Map<String, dynamic> map, String key, String defaultValue) {
    try {
      final value = map[key];
      if (value == null) return defaultValue;
      return value.toString();
    } catch (_) {
      return defaultValue;
    }
  }

  static double _getDouble(
      Map<String, dynamic> map, String key, double defaultValue) {
    try {
      final value = map[key];
      if (value == null) return defaultValue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? defaultValue;
    } catch (_) {
      return defaultValue;
    }
  }

  static int _getInt(Map<String, dynamic> map, String key, int defaultValue) {
    try {
      final value = map[key];
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString()) ?? defaultValue;
    } catch (_) {
      return defaultValue;
    }
  }

  // Convert to simple map for easy use in UI
  Map<String, dynamic> toSimpleMap() {
    return {
      'location': {'name': locationName},
      'current': {
        'temp_c': tempC,
        'temp_f': tempF,
        'condition': {
          'text': conditionText,
          'icon': conditionIcon,
        },
        'wind_kph': windKph,
        'humidity': humidity,
        'feelslike_c': feelsLikeC,
        'precip_mm': precipMm,
        'pressure_mb': pressureMb,
        'vis_km': visKm,
        'is_day': isDay,
        'last_updated': lastUpdated.toIso8601String(),
      }
    };
  }

  static WeatherData? fromJsonString(String source) {
    try {
      return WeatherData.fromJson(json.decode(source) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
