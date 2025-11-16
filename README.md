# weather_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Notes about Weather API

This project was updated to fetch live weather data from WeatherAPI (https://www.weatherapi.com/) instead of using a static list. The API key is currently defined in `lib/Models/city.dart` as `api_key` for convenience. For production, move the key to a secure storage or environment configuration.

To test the change:

1. Run the app on a device or emulator:

```bash
flutter run
```

2. Tap any city in the list to open the weather page. The app will request current weather for that city from WeatherAPI and display temperature, condition, wind, humidity, feels-like and precipitation.

If you hit rate limits or errors, check the API key in `lib/Models/city.dart` and consider creating your own key at https://www.weatherapi.com/.
