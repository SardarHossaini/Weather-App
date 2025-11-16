import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/Models/citiesList.dart';
import 'package:weather_app/Models/city.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CitiesTile extends StatelessWidget {
  final String cityName;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final double temperature;
  final String weatherCondition;
  final String weatherIcon;
  final bool isCurrentLocation;
  final bool isFavorite;

  const CitiesTile({
    super.key,
    required this.cityName,
    this.onTap,
    this.onFavoriteTap,
    required this.temperature,
    required this.weatherCondition,
    required this.weatherIcon,
    this.isCurrentLocation = false,
    this.isFavorite = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1F3A5F).withOpacity(0.8),
                const Color(0xFF4A6FA5).withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background pattern
              _buildBackgroundPattern(),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Location Icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Icon(
                        isCurrentLocation
                            ? Icons.my_location_rounded
                            : Icons.location_on_rounded,
                        color: Colors.white.withOpacity(0.8),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // City Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                cityName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (isCurrentLocation) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4A6FA5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    "Current",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            weatherCondition,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Temperature and Weather Icon - Moved more to the left
                    Container(
                      width: 80, // Give it fixed width
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${temperature.toStringAsFixed(0)}°',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Use actual weather icon from API
                          Image.network(
                            'https:${weatherIcon}',
                            width: 20,
                            height: 20,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildWeatherIcon(weatherCondition);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Favorite Button - Moved to left side to avoid overlapping
              Positioned(
                top: 12,
                left: 12, // Changed from right to left
                child: GestureDetector(
                  onTap: onFavoriteTap,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_rounded,
                      color: isFavorite
                          ? const Color(0xFFFF6B6B)
                          : Colors.white.withOpacity(0.3),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned(
      right: -20,
      top: -20,
      child: Opacity(
        opacity: 0.05,
        child: Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Color(0xFF4A6FA5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherIcon(String condition) {
    IconData icon;
    Color color;

    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        icon = Icons.wb_sunny_rounded;
        color = const Color(0xFFFFD700);
        break;
      case 'partly cloudy':
      case 'cloudy':
      case 'overcast':
        icon = Icons.cloud_rounded;
        color = Colors.white;
        break;
      case 'rainy':
      case 'rain':
      case 'light rain':
      case 'moderate rain':
        icon = Icons.beach_access_rounded;
        color = const Color(0xFF4A90E2);
        break;
      case 'snowy':
      case 'snow':
      case 'light snow':
        icon = Icons.ac_unit_rounded;
        color = Colors.white;
        break;
      default:
        icon = Icons.wb_sunny_rounded;
        color = const Color(0xFFFFD700);
    }

    return Icon(
      icon,
      color: color,
      size: 24,
    );
  }
}

// New City Details Page
class CityDetailsPage extends StatefulWidget {
  final String cityName;
  final bool isFavorite;

  const CityDetailsPage({
    super.key,
    required this.cityName,
    required this.isFavorite,
  });

  @override
  State<CityDetailsPage> createState() => _CityDetailsPageState();
}

class _CityDetailsPageState extends State<CityDetailsPage> {
  final String _apiKey = '0380d0e84f324486aac191450251611';
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://api.weatherapi.com/v1/current.json?key=$_apiKey&q=${widget.cityName}&aqi=no'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _weatherData = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching weather data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleFavorite() {
    final citiesList = Provider.of<CitiesList>(context, listen: false);
    if (widget.isFavorite) {
      citiesList.removeCity(widget.cityName);
    } else {
      citiesList.addCity(widget.cityName);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1C2E),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F1C2E),
              Color(0xFF1F3A5F),
              Color(0xFF0F1C2E),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button and favorite
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white.withOpacity(0.8),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.cityName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _toggleFavorite,
                      icon: Icon(
                        Icons.favorite_rounded,
                        color: widget.isFavorite
                            ? const Color(0xFFFF6B6B)
                            : Colors.white.withOpacity(0.3),
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                if (_isLoading)
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  )
                else if (_weatherData != null)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Temperature Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF1F3A5F).withOpacity(0.8),
                                  const Color(0xFF4A6FA5).withOpacity(0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${_weatherData!['current']['temp_c'].toStringAsFixed(0)}°',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 64,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Image.network(
                                  'https:${_weatherData!['current']['condition']['icon']}',
                                  width: 64,
                                  height: 64,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _weatherData!['current']['condition']['text'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Additional Details
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                _buildDetailRow('Feels Like',
                                    '${_weatherData!['current']['feelslike_c']}°'),
                                _buildDetailRow('Humidity',
                                    '${_weatherData!['current']['humidity']}%'),
                                _buildDetailRow('Wind Speed',
                                    '${_weatherData!['current']['wind_kph']} km/h'),
                                _buildDetailRow('Pressure',
                                    '${_weatherData!['current']['pressure_mb']} mb'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ListOfCities extends StatefulWidget {
  const ListOfCities({super.key});

  @override
  State<ListOfCities> createState() => _ListOfCitiesState();
}

class _ListOfCitiesState extends State<ListOfCities> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Cities> _filteredCities = [];
  final FocusNode _searchFocusNode = FocusNode();
  final String _apiKey = '0380d0e84f324486aac191450251611';

  // Store weather data for each city
  final Map<String, Map<String, dynamic>> _cityWeatherData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialWeatherData();
  }

  Future<void> _loadInitialWeatherData() async {
    final citiesList = Provider.of<CitiesList>(context, listen: false);

    // Fetch weather data for all cities
    for (final city in citiesList.cityList) {
      await _fetchWeatherData(city.cityName);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchWeatherData(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://api.weatherapi.com/v1/current.json?key=$_apiKey&q=$cityName&aqi=no'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _cityWeatherData[cityName] = {
            'temp': data['current']['temp_c'].toDouble(),
            'condition': data['current']['condition']['text'],
            'icon': data['current']['condition']['icon'],
          };
        });
      }
    } catch (e) {
      print('Error fetching weather data for $cityName: $e');
      // Set default data if API fails
      setState(() {
        _cityWeatherData[cityName] = {
          'temp': 20.0,
          'condition': 'Sunny',
          'icon': '//cdn.weatherapi.com/weather/64x64/day/113.png',
        };
      });
    }
  }

  Future<void> _searchAndAddCity(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://api.weatherapi.com/v1/current.json?key=$_apiKey&q=$cityName&aqi=no'),
      );

      if (response.statusCode == 200) {
        // Navigate to city details page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CityDetailsPage(
              cityName: cityName,
              isFavorite: false,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('City not found: $cityName'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterCities(String query, CitiesList citiesList) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (_isSearching) {
        _filteredCities = citiesList.cityList.where((city) {
          return city.cityName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
      _searchFocusNode.unfocus();
    });
  }

  void _showAddCitySheet() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F3A5F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Search City",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter city name...",
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[600]!),
            ),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.pop(context);
              _searchAndAddCity(value.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CitiesList>(
      builder: (context, value, child) => Scaffold(
        backgroundColor: const Color(0xFF0F1C2E),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0F1C2E),
                Color(0xFF1F3A5F),
                Color(0xFF0F1C2E),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 32),

                  // Search Bar
                  _buildAnimatedSearchBar(value),
                  const SizedBox(height: 32),

                  // Cities List
                  _buildCitiesSection(value),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddCitySheet,
          backgroundColor: const Color(0xFF4A6FA5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add, size: 28),
          elevation: 8,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Weather",
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.w300,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              "Your Locations",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A6FA5), Color(0xFF1F3A5F)],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Icon(
            Icons.person,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedSearchBar(CitiesList citiesList) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isSearching ? const Color(0xFF4A6FA5) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: "Search city...",
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.search_rounded,
                    color: Colors.white.withOpacity(0.7),
                    size: 24,
                  ),
                ),
                onChanged: (query) => _filterCities(query, citiesList),
              ),
            ),
          ),
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: _clearSearch,
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCitiesSection(CitiesList citiesList) {
    final citiesToShow = _isSearching ? _filteredCities : citiesList.cityList;
    final isEmpty = citiesToShow.isEmpty;

    if (_isLoading) {
      return _buildLoadingState();
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 20),
            child: Text(
              _isSearching
                  ? "Search Results"
                  : "Favorite Cities (${citiesToShow.length})",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          isEmpty
              ? _buildEmptyState()
              : _buildCitiesList(citiesToShow, citiesList),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 20),
            Text(
              "Loading weather data...",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCitiesList(List<Cities> cities, CitiesList citiesList) {
    return Expanded(
      child: RefreshIndicator(
        backgroundColor: const Color(0xFF1F3A5F),
        color: Colors.white,
        onRefresh: () async {
          await _loadInitialWeatherData();
        },
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: cities.length,
          itemBuilder: (context, index) {
            final city = cities[index];
            final weatherData = _cityWeatherData[city.cityName] ??
                {"temp": 20.0, "condition": "Loading...", "icon": ""};

            return CitiesTile(
              cityName: city.cityName,
              temperature: weatherData["temp"],
              weatherCondition: weatherData["condition"],
              weatherIcon: weatherData["icon"],
              isCurrentLocation: index == 0,
              isFavorite: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CityDetailsPage(
                      cityName: city.cityName,
                      isFavorite: true,
                    ),
                  ),
                );
              },
              onFavoriteTap: () {
                citiesList.removeCity(city.cityName);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isSearching
                    ? Icons.search_off_rounded
                    : Icons.add_location_alt_rounded,
                size: 50,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _isSearching ? "No cities found" : "No favorite cities",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isSearching
                  ? "Try searching for a different city name"
                  : "Add your first city to see weather information",
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
