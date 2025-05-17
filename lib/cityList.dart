import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CityList extends StatefulWidget {
  const CityList({super.key});

  @override
  State<CityList> createState() => _CityListState();
}

class _CityListState extends State<CityList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[300],
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchBar(
              leading: Icon(
                Icons.search,
                color: Colors.blue,
              ),
              padding: MaterialStateProperty.all(
                  EdgeInsets.only(left: 20, right: 20)),
              hintText: "Enter your city name ...",
              backgroundColor: MaterialStateProperty.all(
                Colors.blue[100],
              ),
              trailing: [
                Icon(
                  Icons.arrow_circle_right,
                  color: Colors.blue,
                ),
              ],
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))),
            ),
            Text(
              "Cities List:",
            ),
            // CityLists(),
          ],
        ),
      ),
    );
  }
}
