import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/citiesTile.dart';
import '../models/citiesList.dart';
import '../models/city.dart';
import 'city_details_page.dart';
import '../services/weather_service.dart';
import '../models/weather_api_model.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ListOfCities extends StatefulWidget {
  const ListOfCities({super.key});

  @override
  State<ListOfCities> createState() => _ListOfCitiesState();
}

class _ListOfCitiesState extends State<ListOfCities> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final Map<String, Map<String, dynamic>> _cityWeatherData = {};
  bool _isLoading = true;

  // Search states
  bool _isSearching = false;
  List<Cities> _filteredCities = [];
  List<WeatherData> _searchResults = [];
  bool _isSearchingAPI = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadInitialWeatherData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialWeatherData() async {
    final citiesList = Provider.of<CitiesList>(context, listen: false);
    for (final city in citiesList.cityList) {
      await _fetchWeatherData(city.cityName);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchWeatherData(String cityName) async {
    final data = await WeatherService.fetchWeatherData(cityName);
    setState(() {
      _cityWeatherData[cityName] = data != null
          ? {
              'temp': data['current']['temp_c'].toDouble(),
              'condition': data['current']['condition']['text'],
              'icon': data['current']['condition']['icon'],
            }
          : WeatherService.getDefaultWeatherData();
    });
  }

  void _onSearchChanged(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _isSearchingAPI = false;
        _searchResults.clear();
        _filteredCities.clear();
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Debounce search to avoid too many API calls
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    final citiesList = Provider.of<CitiesList>(context, listen: false);

    // First search in local favorites
    final localResults = citiesList.cityList.where((city) {
      return city.cityName.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (localResults.isNotEmpty) {
      setState(() {
        _filteredCities = localResults;
        _searchResults.clear();
        _isSearchingAPI = false;
      });
      return;
    }

    // If no local results, search via API for multiple cities
    setState(() {
      _isSearchingAPI = true;
      _searchResults.clear();
      _filteredCities.clear();
    });

    try {
      // Use WeatherAPI's search/autocomplete endpoint
      final encodedQuery = Uri.encodeComponent(query);
      const apiKey = '0380d0e84f324486aac191450251611';
      final url = Uri.parse(
          'http://api.weatherapi.com/v1/search.json?key=$apiKey&q=$encodedQuery');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> searchResults = json.decode(response.body);

        if (searchResults.isNotEmpty) {
          // Fetch weather data for each found city (limit to 8 to avoid too many API calls)
          final List<WeatherData> weatherDataList = [];

          for (final cityData in searchResults.take(8)) {
            try {
              final cityName = cityData['name']?.toString() ?? '';
              final country = cityData['country']?.toString() ?? '';
              final region = cityData['region']?.toString() ?? '';

              if (cityName.isNotEmpty) {
                ;

                final weatherUrl = Uri.parse(
                    'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=${Uri.encodeComponent(cityName)}&aqi=no');

                final weatherResponse = await http.get(weatherUrl);
                if (weatherResponse.statusCode == 200) {
                  final weatherJson = json.decode(weatherResponse.body);
                  final weatherData = WeatherData.fromJson(weatherJson);
                  weatherDataList.add(weatherData);
                }
              }
            } catch (e) {
              print('💥 Error fetching weather for city: $e');
            }

            // Small delay to avoid hitting API rate limits
            await Future.delayed(const Duration(milliseconds: 100));
          }

          setState(() {
            _searchResults = weatherDataList;
            _isSearchingAPI = false;
          });
        } else {
          setState(() {
            _searchResults = [];
            _isSearchingAPI = false;
          });
        }
      } else {
        setState(() {
          _searchResults = [];
          _isSearchingAPI = false;
        });
        // Fallback to single city search
        _fallbackSingleCitySearch(query);
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearchingAPI = false;
      });
      // Fallback to single city search
      _fallbackSingleCitySearch(query);
    }
  }

// Fallback method for single city search
  Future<void> _fallbackSingleCitySearch(String query) async {
    try {
      const apiKey = '0380d0e84f324486aac191450251611';
      final url = Uri.parse(
          'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=${Uri.encodeComponent(query)}&aqi=no');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final weatherData = WeatherData.fromJson(data);
        setState(() {
          _searchResults = [weatherData];
        });
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    } catch (e) {;
      setState(() {
        _searchResults = [];
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
      _isSearchingAPI = false;
      _searchResults.clear();
      _filteredCities.clear();
      _searchFocusNode.unfocus();
    });
  }

  void _addToFavorites(WeatherData weatherData) {
    final citiesList = Provider.of<CitiesList>(context, listen: false);
    final cityName = weatherData.locationName;

    

    // Add city to favorites
    citiesList.addCity(cityName);

    // Store weather data
    setState(() {
      _cityWeatherData[cityName] = {
        'temp': weatherData.tempC,
        'condition': weatherData.conditionText,
        'icon': weatherData.conditionIcon,
      };
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$cityName added to favorites!'),
        backgroundColor: Colors.green,
      ),
    );

    // Clear search and show favorites
    _clearSearch();
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
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildSearchBar(),
                  const SizedBox(height: 32),
                  _buildCitiesSection(value),
                ],
              ),
            ),
          ),
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

  Widget _buildSearchBar() {
    return Container(
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
                  hintText: "Search your favorites or worldwide cities...",
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.search_rounded,
                    color: Colors.white.withOpacity(0.7),
                    size: 24,
                  ),
                ),
                onChanged: _onSearchChanged,
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
    final isEmpty = citiesToShow.isEmpty && _searchResults.isEmpty;

    if (_isLoading && !_isSearchingAPI) {
      return _buildLoadingState("Loading weather data...");
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_searchResults.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 20),
              child: Row(
                children: [
                  Text(
                    "Search Results - Tap heart to add to favorites",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.7),
                    size: 16,
                  ),
                ],
              ),
            ),
            _buildSearchResultsList(),
          ] else if (_isSearchingAPI) ...[
            _buildLoadingState("Searching worldwide cities..."),
          ] else if (_filteredCities.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 20),
              child: Text(
                "Search Results in Favorites (${_filteredCities.length})",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            _buildCitiesList(_filteredCities, citiesList),
          ] else ...[
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
        ],
      ),
    );
  }

  Widget _buildSearchResultsList() {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "Found ${_searchResults.length} cities - Tap heart to add to favorites",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final weatherData = _searchResults[index];

                return CitiesTile(
                  cityName: weatherData.locationName,
                  temperature: weatherData.tempC,
                  weatherCondition: weatherData.conditionText,
                  weatherIcon: weatherData.conditionIcon,
                  isCurrentLocation: false,
                  isFavorite: false, // Not in favorites yet
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CityDetailsPage(
                          cityName: weatherData.locationName,
                          isFavorite: false,
                        ),
                      ),
                    );
                  },
                  onFavoriteTap: () {
                    _addToFavorites(weatherData);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(String message) {
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
              message,
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
        onRefresh: _loadInitialWeatherData,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: cities.length,
          itemBuilder: (context, index) {
            final city = cities[index];
            final weatherData = _cityWeatherData[city.cityName] ??
                WeatherService.getDefaultWeatherData();

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
                  : "Search for cities worldwide using the search bar above",
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
}
