import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'lifestyle_screen.dart';
import 'agri_screen.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../models/weather_model.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // LIFTED STATE: The master engine now lives here
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();

  WeatherModel? _weather;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchWeatherForCurrentLocation(); // Fetch data the moment the app opens
  }

  // The Master GPS Fetcher
  Future<void> _fetchWeatherForCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final coordinates = await _locationService.getCurrentLocation();
      await _fetchWeatherData(coordinates);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // The Master Search Fetcher
  Future<void> _fetchWeatherData(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _weatherService.fetchWeather(query);
      setState(() {
        _weather = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // We dynamically rebuild the screens, passing the fresh data down to them
    final List<Widget> screens = [
      HomeScreen(
        weather: _weather,
        isLoading: _isLoading,
        errorMessage: _errorMessage,
        onRefreshLocation: _fetchWeatherForCurrentLocation,
        onSearch: _fetchWeatherData,
      ),
      LifestyleScreen(weather: _weather),
      AgriScreen(weather: _weather),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.black87,
        indicatorColor: Colors.blueAccent.withOpacity(0.3), 
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.cloud_outlined),
            selectedIcon: Icon(Icons.cloud, color: Colors.blueAccent),
            label: 'Forecast',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_run_outlined),
            selectedIcon: Icon(Icons.directions_run, color: Colors.purpleAccent),
            label: 'Lifestyle',
          ),
          NavigationDestination(
            icon: Icon(Icons.grass_outlined),
            selectedIcon: Icon(Icons.grass, color: Colors.greenAccent),
            label: 'Agri',
          ),
        ],
      ),
    );
  }
}