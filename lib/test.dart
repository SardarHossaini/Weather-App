import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  Future<List<String>> getCity() async {
    final cities = await csc.getStatesOfCountry('AF');
    ; // getAllCities should return List<String>
    return cities.map((city) => city.name).toList();
  }

  // Future<List<String>> getCity() async {
  //   final states = await csc.getAllCities();
  //   return states;
  // }
  List<String> city = [];

  @override
  void initState() {
    super.initState();
    loadCities();
  }

  void loadCities() async {
    List<String> cities = await getCity();
    setState(() {
      city = cities;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          for (int i = 0; i < city.length; i++) Text(city[i]),
        ],
      ),
    );
  }
}
