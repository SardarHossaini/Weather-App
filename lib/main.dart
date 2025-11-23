import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/citiesList.dart';
import 'screens/list_of_cities.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CitiesList(),
      child: MaterialApp(
        title: 'Weather App',
        theme: ThemeData.dark(),
        home: const ListOfCities(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
