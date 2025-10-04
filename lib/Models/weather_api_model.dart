// ignore_for_file: file_names

import 'dart:convert';

class WeatherData {
  final String locationName;
  final DateTime lastUpdated;
  final String conditionText;
  final double tempC;
  final double? tempF;
  final double? windKph;
  final int humidity;
  final double? tempMinC;
  final double? tempMaxC;
  final double? feelsLikeC;
  final double? precipMm;

  WeatherData({
    required this.locationName,
    required this.lastUpdated,
    required this.conditionText,
    required this.tempC,
    this.tempF,
    this.windKph,
    required this.humidity,
    this.tempMinC,
    this.tempMaxC,
    this.feelsLikeC,
    this.precipMm,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final location = json['location'] ?? {};
    final current = json['current'] ?? {};
    final condition = current['condition'] ?? {};

    // WeatherAPI returns last_updated as string like "2025-10-04 10:00"
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(
          (current['last_updated'] ?? location['localtime'])
              .toString()
              .replaceAll(' ', 'T'));
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return WeatherData(
      locationName: location['name'] ?? '',
      lastUpdated: parsedDate,
      conditionText: condition['text'] ?? '',
      tempC: (current['temp_c'] ?? 0).toDouble(),
      tempF: current['temp_f'] != null
          ? (current['temp_f'] as num).toDouble()
          : null,
      windKph: current['wind_kph'] != null
          ? (current['wind_kph'] as num).toDouble()
          : null,
      humidity: (current['humidity'] ?? 0) as int,
      tempMinC: null,
      tempMaxC: null,
      feelsLikeC: current['feelslike_c'] != null
          ? (current['feelslike_c'] as num).toDouble()
          : null,
      precipMm: current['precip_mm'] != null
          ? (current['precip_mm'] as num).toDouble()
          : null,
    );
  }

  static WeatherData? fromJsonString(String source) {
    try {
      return WeatherData.fromJson(json.decode(source) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
