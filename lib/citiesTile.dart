import 'package:flutter/material.dart';
import 'package:weather_app/weather_page.dart';

class CitiesTile extends StatelessWidget {
  final String cityName;
  const CitiesTile({super.key, required this.cityName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.blue[50],
      ),
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return WeatherPage();
          }));
        },
        iconColor: Colors.blue,
        title: Text(cityName),
        leading: Icon(Icons.info),
        trailing: Icon(Icons.arrow_circle_right),
      ),
    );
  }
}
