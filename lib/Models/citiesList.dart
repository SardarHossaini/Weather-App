// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:weather_app/Models/city.dart';

class CitiesList extends ChangeNotifier {
  final List<Cities> _cities = [
    Cities(cityName: "Kabul"),
    Cities(cityName: "Herat"),
    Cities(cityName: "Khandahar"),
    Cities(cityName: "Ghor"),
    Cities(cityName: "Konar"),
  ];

  List<Cities> get cityList => _cities;

  void addItemToCart(Cities city) {
    _cities.add(city);
    notifyListeners();
  }

  // Add this method to add cities by name
  void addCity(String cityName) {
    // Check if city already exists to avoid duplicates
    if (!_cities
        .any((city) => city.cityName.toLowerCase() == cityName.toLowerCase())) {
      _cities.add(Cities(cityName: cityName));
      notifyListeners();
    }
  }

  // Optional: Method to remove a city
  void removeCity(String cityName) {
    _cities.removeWhere(
        (city) => city.cityName.toLowerCase() == cityName.toLowerCase());
    notifyListeners();
  }

  // Optional: Method to check if city exists
  bool containsCity(String cityName) {
    return _cities
        .any((city) => city.cityName.toLowerCase() == cityName.toLowerCase());
  }
}
