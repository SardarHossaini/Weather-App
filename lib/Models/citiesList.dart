import 'package:flutter/material.dart';
import 'city.dart';

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

  void addCity(String cityName) {
    if (!_cities
        .any((city) => city.cityName.toLowerCase() == cityName.toLowerCase())) {
      _cities.add(Cities(cityName: cityName));
      notifyListeners();
    }
  }

  void removeCity(String cityName) {
    _cities.removeWhere(
        (city) => city.cityName.toLowerCase() == cityName.toLowerCase());
    notifyListeners();
  }

  bool containsCity(String cityName) {
    return _cities
        .any((city) => city.cityName.toLowerCase() == cityName.toLowerCase());
  }
}
