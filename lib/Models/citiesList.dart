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
}
