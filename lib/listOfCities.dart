import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/Models/citiesList.dart';
import 'package:weather_app/Models/city.dart';
import 'package:weather_app/citiesTile.dart';

class ListOfCities extends StatefulWidget {
  const ListOfCities({super.key});

  @override
  State<ListOfCities> createState() => _ListOfCitiesState();
}

class _ListOfCitiesState extends State<ListOfCities> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CitiesList>(
      builder: (context, value, child) => Scaffold(
        backgroundColor: Colors.blue[300],
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchBar(
                  hintText: "Enter your city name ...",
                  backgroundColor: WidgetStateProperty.all(Colors.blue[50]),
                  leading: const Icon(
                    Icons.search,
                    color: Colors.blue,
                  ),
                  trailing: const [
                    Icon(
                      Icons.arrow_circle_right,
                      color: Colors.blue,
                    )
                  ],
                  padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 20)),
                ),
                const SizedBox(
                  height: 25,
                ),
                const Text(
                  "List Of Cities:",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: ListView.builder(
                        itemCount: value.cityList.length,
                        itemBuilder: (context, index) {
                          Cities eachCity = value.cityList[index];
                          return CitiesTile(cityName: eachCity.cityName);
                        }))
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.blue[50],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
