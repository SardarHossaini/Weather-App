import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/Models/citiesList.dart';
import 'package:weather_app/listOfCities.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CitiesList(),
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            // useMaterial3: true,
            ),
        // home: IntroPage(),
        home: const ListOfCities(),
      ),
    );
  }
}
