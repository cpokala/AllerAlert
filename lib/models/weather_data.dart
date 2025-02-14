// lib/models/weather_data.dart

class WeatherData {
  final double temperature;
  final int humidity;
  final double pressure;
  final double windSpeed;
  final int? weatherCode;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    this.weatherCode,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final values = json['data']['values'];
    return WeatherData(
      temperature: (values['temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (values['humidity'] as num?)?.toInt() ?? 0,
      pressure: (values['pressureSurfaceLevel'] as num?)?.toDouble() ?? 0.0,
      windSpeed: (values['windSpeed'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (values['weatherCode'] as num?)?.toInt(),
    );
  }

  factory WeatherData.defaultData() {
    return WeatherData(
      temperature: 0.0,
      humidity: 0,
      pressure: 0.0,
      windSpeed: 0.0,
      weatherCode: 1000,
    );
  }

  String getWeatherCondition() {
    if (weatherCode == null) return 'Unknown';

    switch (weatherCode!) {
      case 1000:
        return 'Clear';
      case 1001:
        return 'Cloudy';
      case 1100:
        return 'Mostly Clear';
      case 1101:
        return 'Partly Cloudy';
      case 1102:
        return 'Mostly Cloudy';
      case 4000:
        return 'Drizzle';
      case 4001:
        return 'Rain';
      case 4200:
        return 'Light Rain';
      case 4201:
        return 'Heavy Rain';
      case 5000:
        return 'Snow';
      case 5001:
        return 'Flurries';
      case 5100:
        return 'Light Snow';
      case 5101:
        return 'Heavy Snow';
      default:
        return 'Unknown';
    }
  }
}