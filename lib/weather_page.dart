import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:weather/weather.dart';
import 'package:weather_app/Models/city.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherFactory _wf = WeatherFactory(api_key);
  Weather? _weather;

  @override
  void initState() {
    super.initState();
    _wf.currentWeatherByCityName("Kabul").then((w) => {
          setState(() {
            _weather = w;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[300],
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    if (_weather == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _locationHeader(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.08,
          ),
          _dateTimeInfo(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.05,
          ),
          _weatherIcon(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.02,
          ),
          _currentTump(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.02,
          ),
          _extraInfo(),
        ],
      ),
    );
  }

  Widget _locationHeader() {
    return Text(
      _weather?.areaName ?? "",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
    );
  }

  Widget _dateTimeInfo() {
    DateTime now = _weather!.date!;
    return Column(
      children: [
        Text(
          DateFormat('h:mm a').format(now),
          style: TextStyle(fontSize: 28),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat('EEEE').format(now),
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              "  ${DateFormat('d.m.y').format(now)}",
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
          ],
        )
      ],
    );
  }

  Widget getWeatherIcon(String? description) {
    switch (description) {
      case "clear sky":
        return Container(
          height: MediaQuery.sizeOf(context).height * 0.3,
          child: Lottie.asset('assets/animations/suny.json'),
        );
      case "few clouds" ||
            "scattered clouds" ||
            "broken clouds" ||
            "overcast clouds":
        return Container(
          height: MediaQuery.sizeOf(context).height * 0.3,
          child: Lottie.asset('assets/animations/sun_cloud.json'),
        );
      case "light rain" ||
            "moderate rain" ||
            "heavy intensity rain" ||
            "very heavy rain" ||
            "extreme rain" ||
            "freezing rain" ||
            "light intensity shower rain" ||
            "shower rain" ||
            "heavy intensity shower rain" ||
            "ragged shower rain":
        return Container(
          height: MediaQuery.sizeOf(context).height * 0.3,
          child: Lottie.asset('assets/animations/rany.json'),
        );
      case "light snow" ||
            "snow" ||
            "heavy snow" ||
            "sleet" ||
            "light shower sleet" ||
            "shower sleet" ||
            "light rain and snow" ||
            "rain and snow" ||
            "light shower snow" ||
            "shower snow" ||
            "heavy shower snow":
        return Container(
          height: MediaQuery.sizeOf(context).height * 0.3,
          child: Lottie.asset('assets/animations/snowy.json'),
        );
      case "thunderstorm with light rain" ||
            "thunderstorm with rain" ||
            "thunderstorm with heavy rain" ||
            "light thunderstorm" ||
            "thunderstorm" ||
            "heavy thunderstorm" ||
            "ragged thunderstorm" ||
            "thunderstorm with light drizzle" ||
            "thunderstorm with drizzle" ||
            "thunderstorm with heavy drizzl":
        return Container(
          height: MediaQuery.sizeOf(context).height * 0.3,
          child: Lottie.asset('assets/animations/stormy.json'),
        );
      default:
        return Icon(Icons.help_outline, color: Colors.black45);
    }
  }

  Widget _weatherIcon() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        getWeatherIcon(_weather?.weatherDescription),
        Text(_weather?.weatherDescription ?? ""),
      ],
    );
  }

  Widget _currentTump() {
    return Text(
      "${_weather?.temperature?.celsius?.toStringAsFixed(0)}° C",
      style: TextStyle(fontSize: 20),
    );
  }

  Widget _extraInfo() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.15,
      width: MediaQuery.sizeOf(context).width * 0.8,
      decoration: BoxDecoration(
          color: Colors.blue, borderRadius: BorderRadius.circular(20)),
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Max: ${_weather?.tempMax?.celsius?.toStringAsFixed(0)}° C",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              Text(
                "Min: ${_weather?.tempMin?.celsius?.toStringAsFixed(0)}° C",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Wind: ${_weather?.windSpeed?.toStringAsFixed(0)}m/s",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              Text(
                "Humidity: ${_weather?.humidity?.toStringAsFixed(0)}%",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
