import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DiaryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // List of potential API endpoints for NER
  static final List<String> _apiUrls = [
    'https://cpokala-alleralert-phi-ner.hf.space/api/predict',
    'https://api-inference.huggingface.co/models/cpokala/alleralert-phi-ner',
    'https://cpokala-alleralert-phi-ner.hf.space/run/predict',
    'https://huggingface.co/spaces/cpokala/alleralert-phi-ner/api'
  ];

  // Process diary text with NER (tries remote API first, then falls back to local)
  Future<Map<String, dynamic>> processText(String text) async {
    // Validate input
    if (text.trim().isEmpty) {
      return {'entities': []};
    }

    // Try each API URL
    for (final apiUrl in _apiUrls) {
      try {
        // Prepare request data
        final requestData = {
          'data': [text]
        };

        // Add longer timeout since HF Spaces can be slow to respond
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestData),
        ).timeout(const Duration(seconds: 15));

        // Debug logging
        if (kDebugMode) {
          print('API URL: $apiUrl');
          print('API response status: ${response.statusCode}');
          print('API response body: ${response.body}');
        }

        // Check for successful response
        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);

          // Extract data based on potential Gradio API response formats
          if (result is Map && result.containsKey('data') &&
              result['data'] is List &&
              result['data'].isNotEmpty) {
            if (kDebugMode) {
              print('Successfully used Remote NER API');
            }
            return Map<String, dynamic>.from(result['data'][0]);
          } else if (result is Map) {
            // Alternative response format handling
            return Map<String, dynamic>.from(result);
          } else if (result is List) {
            return {'entities': result};
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error with API $apiUrl: $e');
        }
        // Continue to next URL if this one fails
        continue;
      }
    }

    // Fallback to local processing if all APIs fail
    return _processLocally(text);
  }

  // Save diary entry to Firestore
  Future<void> saveDiaryEntry({
    required String text,
    required Map<String, dynamic> nerResults,
    Map<String, dynamic>? environmentalData,
    Map<String, bool>? symptoms,
    int? mood,
  }) async {
    try {
      // Check if user is logged in
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create a entry document with structured data
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('diaryEntries')
          .add({
        'timestamp': FieldValue.serverTimestamp(),
        'text': text,
        'nerResults': nerResults,
        'environmentalData': environmentalData ?? {},
        'symptoms': symptoms ?? {},
        'mood': mood,
        'date': DateTime.now(),
      });

      if (kDebugMode) {
        print('Diary entry saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving diary entry: $e');
      }
      rethrow;
    }
  }

  // Get all diary entries for the current user
  Stream<QuerySnapshot> getDiaryEntries() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('diaryEntries')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get a single diary entry by id
  Future<DocumentSnapshot> getDiaryEntry(String entryId) {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('diaryEntries')
        .doc(entryId)
        .get();
  }

  // Get entity statistics for a user's diary entries
  Future<Map<String, dynamic>> getEntityStatistics() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Get all diary entries
      final entriesSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('diaryEntries')
          .get();

      // Initialize statistics maps
      Map<String, int> symptomCounts = {};
      Map<String, int> foodTriggerCounts = {};
      Map<String, int> placeCounts = {};
      Map<String, int> environmentalTriggerCounts = {};
      Map<String, int> activityTriggerCounts = {};
      Map<String, int> medicationCounts = {};

      // Process each entry
      for (var doc in entriesSnapshot.docs) {
        final data = doc.data();
        final nerResults = data['nerResults'] ?? {'entities': []};
        final entities = nerResults['entities'] as List<dynamic>? ?? [];

        // Count each entity type
        for (var entity in entities) {
          final type = entity['type'] as String? ?? '';
          final text = entity['text'] as String? ?? '';

          if (text.isEmpty) continue;

          switch (type) {
            case 'SYMPTOM':
              symptomCounts[text] = (symptomCounts[text] ?? 0) + 1;
              break;
            case 'FOOD_TRIGGER':
              foodTriggerCounts[text] = (foodTriggerCounts[text] ?? 0) + 1;
              break;
            case 'PLACE':
              placeCounts[text] = (placeCounts[text] ?? 0) + 1;
              break;
            case 'ENVIRONMENT_TRIGGER':
              environmentalTriggerCounts[text] = (environmentalTriggerCounts[text] ?? 0) + 1;
              break;
            case 'ACTIVITY_TRIGGER':
              activityTriggerCounts[text] = (activityTriggerCounts[text] ?? 0) + 1;
              break;
            case 'MEDICATION':
              medicationCounts[text] = (medicationCounts[text] ?? 0) + 1;
              break;
          }
        }
      }

      // Return consolidated statistics
      return {
        'symptoms': symptomCounts,
        'foodTriggers': foodTriggerCounts,
        'places': placeCounts,
        'environmentalTriggers': environmentalTriggerCounts,
        'activityTriggers': activityTriggerCounts,
        'medications': medicationCounts,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting entity statistics: $e');
      }
      rethrow;
    }
  }

  // Local NER processing as a fallback
  Map<String, dynamic> _processLocally(String text) {
    if (kDebugMode) {
      print('Using local NER processing');
    }

    final entities = <Map<String, dynamic>>[];
    final textLower = text.toLowerCase();

    // Time expressions with regex
    final timePatterns = [
      RegExp(r'(\d{1,2}(?::\d{2})?\s*(?:am|pm|AM|PM))'),  // 5 pm, 5:30 PM
      RegExp(r'(yesterday|today|tomorrow|last night|this morning|this afternoon|this evening|tonight)'),
      RegExp(r'(around|at|about)\s+(\d{1,2}(?::\d{2})?\s*(?:am|pm|AM|PM))'),  // at 5 pm, around 7pm
      RegExp(r'(\d{1,2})\s*(?::|hr|hour)s?\s+(?:ago|later|after)'),  // 2 hours ago, 3 hrs later
      RegExp(r'(morning|afternoon|evening|night|midnight|noon)'),
      RegExp(r'(early|late)\s+(morning|afternoon|evening|night)'),
      RegExp(r'(before|after)\s+(breakfast|lunch|dinner|meal|supper)'),
    ];

    for (final pattern in timePatterns) {
      final matches = pattern.allMatches(textLower);
      for (final match in matches) {
        final timeExpr = match.group(0)!;
        entities.add({
          'type': 'TIME',
          'text': timeExpr,
          'confidence': 0.85
        });
      }
    }

    // Places
    final places = [
      'home', 'house', 'apartment', 'condo',
      'school', 'classroom', 'university', 'college', 'campus',
      'work', 'office', 'workplace', 'job', 'cubicle',
      'hospital', 'clinic', 'doctor', 'emergency room', 'urgent care',
      'park', 'garden', 'yard', 'playground', 'field', 'outdoor',
      'gym', 'fitness center', 'pool', 'track', 'stadium',
      'store', 'mall', 'shop', 'supermarket', 'grocery',
      'restaurant', 'cafe', 'coffee shop', 'bar', 'club',
      'church', 'temple', 'mosque', 'synagogue',
      'car', 'bus', 'train', 'subway', 'plane', 'airport',
      'basement', 'attic', 'bathroom', 'kitchen'
    ];

    for (final place in places) {
      if (textLower.contains(place)) {
        entities.add({
          'type': 'PLACE',
          'text': place,
          'confidence': 0.85
        });
      }
    }

    // Check for location context patterns
    final locationContextPattern = RegExp(r'(at|in|to|near|by|from)\s+(?:the|a|an)?\s+([a-zA-Z\s]+)');
    final locationMatches = locationContextPattern.allMatches(textLower);
    for (final match in locationMatches) {
      final placeExpr = match.group(2)?.trim() ?? '';
      if (placeExpr.isNotEmpty && placeExpr.split(' ').length <= 3) {
        for (final place in places) {
          if (placeExpr.contains(place)) {
            entities.add({
              'type': 'PLACE',
              'text': placeExpr,
              'confidence': 0.8
            });
            break;
          }
        }
      }
    }

    // Symptoms
    final symptoms = [
      'wheez', 'wheezing', 'whistle', 'whistling',
      'breathless', 'breathlessness', 'shortness of breath', 'short of breath',
      'tight chest', 'chest tightness', 'chest pressure', 'chest pain',
      'cough', 'coughing', 'hack', 'dry cough', 'wet cough',
      'mucus', 'phlegm', 'congestion', 'congested',
      'fatigue', 'tired', 'exhausted', 'weakness',
      'dizzy', 'dizziness', 'lightheaded', 'faint',
      'throat', 'sore throat', 'scratchy throat', 'itchy throat',
      'sneezing', 'sneeze', 'runny nose', 'stuffy nose', 'blocked nose',
      'itchy eyes', 'watery eyes', 'eye irritation', 'red eyes',
      'headache', 'migraine', 'head pressure', 'sinus pain',
      'rash', 'hives', 'itchy', 'itch', 'swelling', 'swollen',
      'attack', 'asthma attack', 'flare', 'flare-up'
    ];

    for (final symptom in symptoms) {
      if (textLower.contains(symptom)) {
        entities.add({
          'type': 'SYMPTOM',
          'text': symptom,
          'confidence': 0.95
        });
      }
    }

    // Complex symptom patterns
    final symptomPatterns = [
      RegExp(r'(felt|feeling|having|had|experiencing|started|began)\s+(to\s+)?(feel\s+)?(.*?)(breathless|short of breath|difficulty breathing)'),
      RegExp(r'(chest\s+(?:tightness|pain|pressure|discomfort|heaviness))'),
      RegExp(r'((?:runny|stuffy|itchy|blocked)\s+(?:nose|eyes|throat))'),
      RegExp(r'((?:hard|difficult|trouble|struggling)\s+(?:to breathe|breathing))'),
      RegExp(r'(woke up|awakened)\s+(?:from|by|with|due to)\s+(?:coughing|wheezing|breathlessness|asthma)'),
    ];

    for (final pattern in symptomPatterns) {
      final matches = pattern.allMatches(textLower);
      for (final match in matches) {
        final symptomExpr = match.group(0)!;
        entities.add({
          'type': 'SYMPTOM',
          'text': symptomExpr,
          'confidence': 0.9
        });
      }
    }

    // Food triggers
    final foods = [
      'nut', 'peanut', 'almond', 'cashew', 'walnut', 'pecan',
      'dairy', 'milk', 'cheese', 'yogurt', 'ice cream', 'butter',
      'wheat', 'gluten', 'bread', 'pasta', 'cereal', 'flour',
      'soy', 'tofu', 'soy sauce',
      'egg', 'shellfish', 'shrimp', 'crab', 'lobster', 'clam',
      'chocolate', 'coffee', 'alcohol', 'wine', 'beer',
      'pizza', 'burger', 'hotdog', 'hot dog', 'sandwich',
      'spicy', 'curry', 'fish', 'seafood'
    ];

    for (final food in foods) {
      if (textLower.contains(food)) {
        entities.add({
            'type': 'FOOD_TRIGGER',
            'text': food,
            'confidence': 0.9
        });
      }
    }

    // Food context patterns
    final foodContextPattern = RegExp(r'(ate|eating|consumed|had|drank|drinking)\s+(?:a|an|some)?\s+([a-zA-Z\s]+)');
    final foodMatches = foodContextPattern.allMatches(textLower);
    for (final match in foodMatches) {
      final foodExpr = match.group(2)?.trim() ?? '';
      if (foodExpr.isNotEmpty && foodExpr.split(' ').length <= 3) {
        for (final food in foods) {
          if (foodExpr.contains(food)) {
            entities.add({
              'type': 'FOOD_TRIGGER',
              'text': foodExpr,
              'confidence': 0.85
            });
            break;
          }
        }
      }
    }

    // Environmental triggers
    final environmentTriggers = [
      'pollen', 'dust', 'mold', 'mildew', 'spore', 'dander', 'pet', 'cat', 'dog', 'fur',
      'smoke', 'cigarette', 'cigar', 'vape', 'tobacco',
      'perfume', 'cologne', 'fragrance', 'scent', 'odor', 'smell',
      'chemical', 'cleaning', 'bleach', 'ammonia', 'paint', 'solvent', 'gas',
      'cold air', 'humidity', 'dry air', 'foggy', 'windy', 'weather',
      'rain', 'thunderstorm', 'storm', 'heat', 'hot', 'cold', 'freeze', 'frost',
      'pollution', 'smog', 'exhaust', 'fume', 'air quality', 'particle',
      'carpet', 'mattress', 'pillow', 'bedding', 'upholstery', 'curtain',
      'spring', 'summer', 'fall', 'autumn', 'winter', 'seasonal'
    ];

    for (final trigger in environmentTriggers) {
      if (textLower.contains(trigger)) {
        entities.add({
          'type': 'ENVIRONMENT_TRIGGER',
          'text': trigger,
          'confidence': 0.9
        });
      }
    }

    // Activity triggers
    final activities = [
      'exercise', 'run', 'jog', 'walk', 'hike', 'swim', 'cycle', 'bike',
      'sport', 'game', 'play', 'basketball', 'football', 'soccer', 'tennis',
      'workout', 'gym', 'cardio', 'training', 'lifting', 'stretch', 'yoga',
      'climb', 'stair', 'chore', 'clean', 'vacuum', 'sweep', 'dust',
      'garden', 'mow', 'rake', 'shovel', 'snow'
    ];

    for (final activity in activities) {
      if (textLower.contains(activity)) {
        entities.add({
          'type': 'ACTIVITY_TRIGGER',
          'text': activity,
          'confidence': 0.9
        });
      }
    }

    // Medication usage
    final medications = [
      'inhaler', 'albuterol', 'ventolin', 'proair', 'rescue inhaler', 'puffer',
      'nebulizer', 'nebuliser', 'breathing treatment',
      'steroid', 'controller', 'maintenance',
      'advair', 'symbicort', 'flovent', 'qvar', 'pulmicort', 'asmanex',
      'singulair', 'montelukast', 'spiriva',
      'antihistamine', 'benadryl', 'zyrtec', 'claritin', 'allegra',
      'decongestant', 'sudafed', 'mucinex',
      'prednisone', 'prednisolone',
      'antibiotics', 'amoxicillin', 'azithromycin',
      'pill', 'tablet', 'medicine', 'medication'
    ];

    for (final medication in medications) {
      if (textLower.contains(medication)) {
        entities.add({
          'type': 'MEDICATION',
          'text': medication,
          'confidence': 0.9
        });
      }
    }

    // Medication context patterns
    final medicationPatterns = [
      RegExp(r'(took|used|taking|using|needed)\s+(?:my|an?|the|some)?\s+([a-zA-Z\s]+)'),
      RegExp(r'(puff|dose|treatment|tablet|pill)\s+of\s+([a-zA-Z\s]+)')
    ];

    for (final pattern in medicationPatterns) {
      final matches = pattern.allMatches(textLower);
      for (final match in matches) {
        if (match.groupCount >= 2) {
          final medExpr = match.group(2)?.trim() ?? '';
          if (medExpr.isNotEmpty && medExpr.split(' ').length <= 4) {
            for (final med in medications) {
              if (medExpr.contains(med)) {
                entities.add({
                  'type': 'MEDICATION',
                  'text': medExpr,
                  'confidence': 0.85
                });
                break;
              }
            }
          }
        }
      }
    }

    // Remove duplicates
    final uniqueEntities = <String, Map<String, dynamic>>{};
    for (final entity in entities) {
      final key = '${entity['type']}_${entity['text']}';
      if (!uniqueEntities.containsKey(key) ||
          uniqueEntities[key]!['confidence'] < entity['confidence']) {
        uniqueEntities[key] = entity;
      }
    }

    return {'entities': uniqueEntities.values.toList()};
  }
}