import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:alleralert_app/Bluetooth/air_quality_reading.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Throttling control
  DateTime? _lastSavedTimestamp;
  static const Duration _savingInterval = Duration(minutes: 2); // Save every 2 minutes

  // Batch collection for averaging
  List<AirQualityReading> _readingsBuffer = [];
  static const int _maxBufferSize = 10; // Collect 10 readings for averaging

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Add a reading to buffer and save if conditions are met
  Future<void> addReading(AirQualityReading reading) async {
    // Add to buffer
    _readingsBuffer.add(reading);

    // Check if enough time has passed since last save
    final now = DateTime.now();
    final shouldSaveByTime = _lastSavedTimestamp == null ||
        now.difference(_lastSavedTimestamp!) >= _savingInterval;

    // Check if buffer is full
    final shouldSaveByBuffer = _readingsBuffer.length >= _maxBufferSize;

    if (shouldSaveByTime || shouldSaveByBuffer) {
      // Time to save the averaged reading
      await _saveAveragedReading();
      _lastSavedTimestamp = now;
    }
  }

  // Average readings and save
  Future<void> _saveAveragedReading() async {
    if (_readingsBuffer.isEmpty) return;

    try {
      // Calculate averages
      double vocSum = 0;
      double tempSum = 0;
      double humiditySum = 0;
      double pressureSum = 0;
      int batterySum = 0;
      Map<String, double> pmSums = {};

      // Sum all values
      for (var reading in _readingsBuffer) {
        vocSum += reading.voc;
        tempSum += reading.temperature;
        humiditySum += reading.humidity;
        pressureSum += reading.pressure;
        batterySum += reading.batteryLevel;

        // Sum particulate matter readings
        reading.particulateMatter.forEach((key, value) {
          pmSums[key] = (pmSums[key] ?? 0) + value;
        });
      }

      // Calculate averages
      final count = _readingsBuffer.length;
      final avgVoc = vocSum / count;
      final avgTemp = tempSum / count;
      final avgHumidity = humiditySum / count;
      final avgPressure = pressureSum / count;
      final avgBattery = (batterySum / count).round();

      // Average particulate matter readings
      Map<String, double> avgPm = {};
      pmSums.forEach((key, sum) {
        avgPm[key] = sum / count;
      });

      // Create averaged reading
      final averagedReading = AirQualityReading(
        voc: avgVoc,
        temperature: avgTemp,
        humidity: avgHumidity,
        pressure: avgPressure,
        batteryLevel: avgBattery,
        particulateMatter: avgPm,
        timestamp: DateTime.now(),
        userId: currentUserId ?? '',
        deviceId: _readingsBuffer.first.deviceId,
      );

      // Save to Firestore
      await _saveToFirestore(averagedReading);

      // Clear buffer
      _readingsBuffer.clear();

    } catch (e) {
      debugPrint('Error averaging readings: $e');
    }
  }

  // Save a reading to Firestore
  Future<void> _saveToFirestore(AirQualityReading reading) async {
    if (currentUserId == null) {
      debugPrint('Cannot save reading: User not logged in');
      return;
    }

    try {
      // Reference to the user's collection
      final userRef = _firestore.collection('users').doc(currentUserId);

      // Create a new document in the air_quality_readings collection
      await userRef.collection('air_quality_readings').add(reading.toMap());

      debugPrint('Air quality reading saved to Firebase');
    } catch (e) {
      debugPrint('Error saving air quality reading: $e');
      rethrow;
    }
  }

  // Force save current buffer contents
  Future<void> forceSave() async {
    if (_readingsBuffer.isNotEmpty) {
      await _saveAveragedReading();
      _lastSavedTimestamp = DateTime.now();
    }
  }

  // Get all air quality readings for current user
  Future<List<AirQualityReading>> getAirQualityReadings() async {
    if (currentUserId == null) {
      debugPrint('Cannot get readings: User not logged in');
      return [];
    }

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('air_quality_readings')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return AirQualityReading.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting air quality readings: $e');
      return [];
    }
  }

  // Get recent air quality readings (last 24 hours)
  Future<List<AirQualityReading>> getRecentAirQualityReadings() async {
    if (currentUserId == null) {
      debugPrint('Cannot get readings: User not logged in');
      return [];
    }

    final DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('air_quality_readings')
          .where('timestamp', isGreaterThan: yesterday.toIso8601String())
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return AirQualityReading.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting recent air quality readings: $e');
      return [];
    }
  }
}