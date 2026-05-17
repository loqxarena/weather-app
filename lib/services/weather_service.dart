import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/weather_model.dart';

class WeatherService {
  Future<WeatherModel> fetchWeather(String query) async {
    // We changed the endpoint from current.json to forecast.json and requested 3 days of data
    final url = Uri.parse(
      '${AppConstants.weatherBaseUrl}/forecast.json?key=${AppConstants.weatherApiKey}&q=$query&days=3&aqi=yes'
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonString = jsonDecode(response.body);
        return WeatherModel.fromJson(jsonString); // Passes the massive JSON to our new blueprint
      } else {
        throw Exception('Failed to load weather: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: Ensure you have internet connection. Details: $e');
    }
  }
}