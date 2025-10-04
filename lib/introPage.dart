import 'package:flutter/material.dart';
import 'package:weather_app/listOfCities.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[300],
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/background.png',
              height: 300,
            ),
            const SizedBox(
              height: 40,
            ),
            Text(
              "Welcome to BLUE SKIES",
              style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 26,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 330,
              child: Text(
                "Your smart and simple way to stay updated with real-time weather.",
                style: TextStyle(color: Colors.blueAccent[400]),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Container(
              width: double.infinity,
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const ListOfCities();
                    }));
                  },
                  child: const Text("Check Weater")),
            )
          ],
        ),
      ),
    );
  }
}
