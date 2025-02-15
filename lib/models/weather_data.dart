// lib/models/weather_data.dart

class WeatherData {
  final double temperature;
  final double temperatureApparent;
  final int humidity;
  final double dewPoint;
  final double visibility;
  final int uvIndex;
  final double precipitationProbability;
  final double rainIntensity;
  final double snowIntensity;
  final double windSpeed;
  final int windDirection;
  final double windGust;
  final double pressure;
  final int weatherCode;
  final double cloudBase;
  final double cloudCeiling;
  final double cloudCover;
  final double freezingRainIntensity;
  final double hailProbability;
  final double pressureSeaLevel;
  final double pressureSurfaceLevel;
  final double sleetIntensity;

  WeatherData({
    this.temperature = 0.0,
    this.temperatureApparent = 0.0,
    this.humidity = 0,
    this.dewPoint = 0.0,
    this.visibility = 0.0,
    this.uvIndex = 0,
    this.precipitationProbability = 0.0,
    this.rainIntensity = 0.0,
    this.snowIntensity = 0.0,
    this.windSpeed = 0.0,
    this.windDirection = 0,
    this.windGust = 0.0,
    this.pressure = 0.0,
    this.weatherCode = 1000,
    this.cloudBase = 0.0,
    this.cloudCeiling = 0.0,
    this.cloudCover = 0.0,
    this.freezingRainIntensity = 0.0,
    this.hailProbability = 0.0,
    this.pressureSeaLevel = 0.0,
    this.pressureSurfaceLevel = 0.0,
    this.sleetIntensity = 0.0,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final values = json['data']['values'];
    return WeatherData(
      temperature: (values['temperature'] ?? 0).toDouble(),
      temperatureApparent: (values['temperatureApparent'] ?? 0).toDouble(),
      humidity: (values['humidity'] ?? 0).toInt(),
      dewPoint: (values['dewPoint'] ?? 0).toDouble(),
      visibility: (values['visibility'] ?? 0).toDouble(),
      uvIndex: (values['uvIndex'] ?? 0).toInt(),
      precipitationProbability: (values['precipitationProbability'] ?? 0).toDouble(),
      rainIntensity: (values['rainIntensity'] ?? 0).toDouble(),
      snowIntensity: (values['snowIntensity'] ?? 0).toDouble(),
      windSpeed: (values['windSpeed'] ?? 0).toDouble(),
      windDirection: (values['windDirection'] ?? 0).toInt(),
      windGust: (values['windGust'] ?? 0).toDouble(),
      pressure: (values['pressureSurfaceLevel'] ?? 0).toDouble(),
      weatherCode: (values['weatherCode'] ?? 1000).toInt(),
      cloudBase: (values['cloudBase'] ?? 0).toDouble(),
      cloudCeiling: (values['cloudCeiling'] ?? 0).toDouble(),
      cloudCover: (values['cloudCover'] ?? 0).toDouble(),
      freezingRainIntensity: (values['freezingRainIntensity'] ?? 0).toDouble(),
      hailProbability: (values['hailProbability'] ?? 0).toDouble(),
      pressureSeaLevel: (values['pressureSeaLevel'] ?? 0).toDouble(),
      pressureSurfaceLevel: (values['pressureSurfaceLevel'] ?? 0).toDouble(),
      sleetIntensity: (values['sleetIntensity'] ?? 0).toDouble(),
    );
  }

  String getWeatherCondition() {
    switch (weatherCode) {
      case 1000:
        return 'Clear';
      case 1100:
        return 'Mostly Clear';
      case 1101:
        return 'Partly Cloudy';
      case 1001:
        return 'Cloudy';
      case 1102:
        return 'Mostly Cloudy';
      case 4000:
        return 'Drizzle';
      case 4200:
        return 'Light Rain';
      case 4001:
        return 'Rain';
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