import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/citiesTile.dart';
import '../models/citiesList.dart';
import '../models/city.dart';
import '../widgets/search_dialog.dart';
import 'city_details_page.dart';
import '../services/weather_service.dart';

class ListOfCities extends StatefulWidget {
  const ListOfCities({super.key});

  @override
  State<ListOfCities> createState() => _ListOfCitiesState();
}

class _ListOfCitiesState extends State<ListOfCities> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dialogSearchController = TextEditingController();
  bool _isSearching = false;
  List<Cities> _filteredCities = [];
  final FocusNode _searchFocusNode = FocusNode();
  final Map<String, Map<String, dynamic>> _cityWeatherData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialWeatherData();
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

  Future<void> _searchAndAddCity(String cityName) async {
    final data = await WeatherService.fetchWeatherData(cityName);
    if (data != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CityDetailsPage(
            cityName: cityName,
            isFavorite: false,
          ),
        ),
      );
    } else {
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
    _dialogSearchController.clear();
    showDialog(
      context: context,
      builder: (context) => SearchDialog(
        onCitySearched: _searchAndAddCity,
        controller: _dialogSearchController,
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
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildAnimatedSearchBar(value),
                  const SizedBox(height: 32),
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
    _dialogSearchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
