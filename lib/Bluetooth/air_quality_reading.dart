class AirQualityReading {
  final double voc;
  final double temperature;
  final double humidity;
  final double pressure;
  final int batteryLevel;
  final Map<String, double> particulateMatter;
  final DateTime timestamp;
  final String userId;
  final String deviceId;

  AirQualityReading({
    required this.voc,
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.batteryLevel,
    required this.particulateMatter,
    required this.timestamp,
    required this.userId,
    required this.deviceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'voc': voc,
      'temperature': temperature,
      'humidity': humidity,
      'pressure': pressure,
      'batteryLevel': batteryLevel,
      'particulateMatter': particulateMatter,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'deviceId': deviceId,
    };
  }

  factory AirQualityReading.fromMap(Map<String, dynamic> map) {
    return AirQualityReading(
      voc: map['voc'] ?? 0.0,
      temperature: map['temperature'] ?? 0.0,
      humidity: map['humidity'] ?? 0.0,
      pressure: map['pressure'] ?? 0.0,
      batteryLevel: map['batteryLevel'] ?? 0,
      particulateMatter: Map<String, double>.from(map['particulateMatter'] ?? {}),
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      userId: map['userId'] ?? '',
      deviceId: map['deviceId'] ?? '',
    );
  }
}