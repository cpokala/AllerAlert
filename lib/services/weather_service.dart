// lib/services/weather_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService {
  final String apiKey = 'axbv3qg741vNBsqAXOgRQejBZXE7VzcI';
  final String baseUrl = 'https://api.tomorrow.io/v4/weather/realtime';

  Future<WeatherData> getCurrentWeather(double latitude, double longitude) async {
    try {
      print('Fetching weather for coordinates: $latitude, $longitude');

      final Uri uri = Uri.parse(
          '$baseUrl?location=$latitude,$longitude&apikey=$apiKey&units=imperial'
      );

      print('Making request to: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return WeatherData.fromJson(jsonData);
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getCurrentWeather: $e');
      // Return a default WeatherData object instead of throwing
      return WeatherData();
    }
  }
}