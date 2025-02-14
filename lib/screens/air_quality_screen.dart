// lib/screens/air_quality_screen.dart

import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../models/weather_data.dart';

class AirQualityScreen extends StatefulWidget {
  const AirQualityScreen({super.key});

  @override
  State<AirQualityScreen> createState() => _AirQualityScreenState();
}

class _AirQualityScreenState extends State<AirQualityScreen> {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  WeatherData? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await _locationService.getCurrentLocation();

      if (position == null) {
        setState(() {
          _errorMessage = 'Unable to get location. Please enable location services and try again.';
          _isLoading = false;
        });
        return;
      }

      final weather = await _weatherService.getCurrentWeather(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _weatherData = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading weather data. Please try again.';
        _isLoading = false;
      });
    }
  }

  Color _getWeatherColor(int weatherCode) {
    switch (weatherCode) {
      case 1000: // Clear
        return const Color(0xFF3BD5FF);
      case 1100: // Mostly Clear
      case 1101: // Partly Cloudy
        return const Color(0xFF87CEEB);
      case 1001: // Cloudy
      case 1102: // Mostly Cloudy
        return const Color(0xFF808080);
      case 4000: // Drizzle
      case 4200: // Light Rain
        return const Color(0xFF4682B4);
      case 4001: // Rain
      case 4201: // Heavy Rain
        return const Color(0xFF000080);
      case 5000: // Snow
      case 5001: // Flurries
      case 5100: // Light Snow
      case 5101: // Heavy Snow
        return const Color(0xFFB0E0E6);
      default:
        return const Color(0xFF3BD5FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.00, -1.00),
            end: Alignment(0, 1),
            colors: [Color(0xFFEBC5FF), Color(0xAA9ADAD5), Color(0xFF957AA3)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button and Refresh Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.black),
                    onPressed: _fetchWeatherData,
                  ),
                ],
              ),

              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF9866B0),
                    ),
                  ),
                )
              else if (_errorMessage != null)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchWeatherData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9866B0),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchWeatherData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Weather Image
                            Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              width: double.infinity,
                              height: 293,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/weather.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            // Weather Details Section
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD9D9D9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Weather Details',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildWeatherDetail(
                                        'Temperature',
                                        '${_weatherData?.temperature.toStringAsFixed(1) ?? '0'} F',
                                      ),
                                      _buildWeatherDetail(
                                        'Humidity',
                                        '${_weatherData?.humidity ?? '0'}%',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildWeatherDetail(
                                        'Pressure',
                                        '${_weatherData?.pressure.toStringAsFixed(0) ?? '0'} hPa',
                                      ),
                                      _buildWeatherDetail(
                                        'Wind Speed',
                                        '${_weatherData?.windSpeed.toStringAsFixed(1) ?? '0'} mph',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Weather Condition Section
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD9D9D9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Weather Condition',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Current Weather',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Text(
                                        _weatherData?.getWeatherCondition() ?? 'Unknown',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  // Weather Condition Indicator
                                  SizedBox(
                                    height: 33,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 9,
                                          decoration: BoxDecoration(
                                            color: _getWeatherColor(_weatherData?.weatherCode ?? 0),
                                            borderRadius: BorderRadius.circular(50),
                                          ),
                                        ),
                                        Container(
                                          width: 33,
                                          height: 33,
                                          decoration: BoxDecoration(
                                            color: _getWeatherColor(_weatherData?.weatherCode ?? 0),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _weatherData?.getWeatherCondition() ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // TODO: Implement detailed forecast
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF9866B0),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          side: const BorderSide(color: Colors.white),
                                        ),
                                      ),
                                      child: const Text(
                                        'View Detailed Forecast',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildWeatherDetail(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}