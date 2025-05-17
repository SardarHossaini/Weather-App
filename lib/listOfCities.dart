import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/Models/citiesList.dart';
// import 'package:weather_app/Models/city.dart';

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
                    children: [
                      SearchBar(
                        hintText: "Enter your city name ...",
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blue[50]),
                        leading: Icon(
                          Icons.search,
                          color: Colors.blue,
                        ),
                        trailing: [
                          Icon(
                            Icons.arrow_circle_right,
                            color: Colors.blue,
                          )
                        ],
                        padding: MaterialStateProperty.all(
                            EdgeInsets.symmetric(horizontal: 20)),
                      ),
                      Text("List Of Cities:"),
                      // Expanded(
                      //     child: ListView.builder(
                      //         itemCount: value.cityList.length,
                      //         itemBuilder: (context, index) {
                      //           // Cities eachCity = value.cityList[index];
                      //           return Text("test");
                      //         }))
                    ],
                  ),
                ),
              ),
            ));
  }
}
