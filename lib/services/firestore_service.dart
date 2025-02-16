import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Create or update user document
  Future<void> createOrUpdateUser(User user) async {
    final userData = {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'lastLogin': DateTime.now(),
    };

    await _db.collection('users').doc(user.uid).set(
      userData,
      SetOptions(merge: true),
    );
  }

  // Log symptoms
  Future<DocumentReference> logSymptoms({
    required int mood,
    required String thoughts,
    required Map<String, bool> symptoms,
  }) async {
    if (currentUserId == null) {
      throw Exception('No authenticated user');
    }

    return await _db
        .collection('users')
        .doc(currentUserId)
        .collection('symptoms_logs')
        .add({
      'date': DateTime.now(),
      'mood': mood,
      'thoughts': thoughts,
      'symptoms': symptoms,
      'createdAt': DateTime.now(),
    });
  }

  // Get symptoms logs
  Future<QuerySnapshot> getSymptomLogs() async {
    if (currentUserId == null) {
      throw Exception('No authenticated user');
    }

    return await _db
        .collection('users')
        .doc(currentUserId)
        .collection('symptoms_logs')
        .get();
  }

  // Add medication
  Future<DocumentReference> addMedication({
    required String name,
    required String dosage,
    required String frequency,
    required String description,
  }) async {
    if (currentUserId == null) {
      throw Exception('No authenticated user');
    }

    return await _db
        .collection('users')
        .doc(currentUserId)
        .collection('medications')
        .add({
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'description': description,
      'isActive': true,
      'startDate': DateTime.now(),
      'createdAt': DateTime.now(),
    });
  }

  // Get medications
  Future<QuerySnapshot> getMedications() async {
    if (currentUserId == null) {
      throw Exception('No authenticated user');
    }

    return await _db
        .collection('users')
        .doc(currentUserId)
        .collection('medications')
        .where('isActive', isEqualTo: true)
        .get();
  }

  // Save weather data
  Future<void> saveWeatherData(Map<String, dynamic> weatherData) async {
    if (currentUserId == null) {
      throw Exception('No authenticated user');
    }

    String today = DateTime.now().toIso8601String().split('T')[0];
    await _db
        .collection('users')
        .doc(currentUserId)
        .collection('weather_data')
        .doc(today)
        .set(weatherData);
  }
}