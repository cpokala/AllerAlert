import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/diary_service.dart';

class DiaryEntryDetailScreen extends StatefulWidget {
  final String entryId;

  const DiaryEntryDetailScreen({
    super.key,
    required this.entryId,
  });

  @override
  State<DiaryEntryDetailScreen> createState() => _DiaryEntryDetailScreenState();
}

class _DiaryEntryDetailScreenState extends State<DiaryEntryDetailScreen> {
  final DiaryService _diaryService = DiaryService();
  bool _isLoading = true;
  Map<String, dynamic> _entryData = {};

  @override
  void initState() {
    super.initState();
    _loadEntryData();
  }

  Future<void> _loadEntryData() async {
    setState(() => _isLoading = true);
    try {
      final doc = await _diaryService.getDiaryEntry(widget.entryId);
      setState(() {
        _entryData = doc.data() as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading diary entry: $e')),
        );
      }
    }
  }

  // Get an appropriate icon for entity type
  IconData _getEntityIcon(String type) {
    switch (type) {
      case 'SYMPTOM':
        return Icons.healing;
      case 'FOOD_TRIGGER':
        return Icons.fastfood;
      case 'PLACE':
        return Icons.place;
      case 'ENVIRONMENT_TRIGGER':
        return Icons.nature;
      case 'ACTIVITY_TRIGGER':
        return Icons.directions_run;
      case 'MEDICATION':
        return Icons.medication;
      case 'TIME':
        return Icons.access_time;
      default:
        return Icons.label;
    }
  }

  // Get an appropriate color for entity type
  Color _getEntityColor(String type) {
    switch (type) {
      case 'SYMPTOM':
        return Colors.red;
      case 'FOOD_TRIGGER':
        return Colors.orange;
      case 'PLACE':
        return Colors.teal;
      case 'ENVIRONMENT_TRIGGER':
        return Colors.green;
      case 'ACTIVITY_TRIGGER':
        return Colors.blue;
      case 'MEDICATION':
        return Colors.purple;
      case 'TIME':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  // Format a field name for display
  String _formatFieldName(String name) {
    return name
        .replaceAllMapped(
        RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .replaceAll('_', ' ')
        .trim()
        .capitalize();
  }

  // Format environmental data values with units
  String _formatEnvironmentalValue(String key, dynamic value) {
    if (value is num) {
      switch (key) {
        case 'voc':
          return '${value.toStringAsFixed(2)} ppm';
        case 'temperature':
          return '${value.toStringAsFixed(1)} °C';
        case 'pressure':
          return '${value.toStringAsFixed(1)} hPa';
        case 'particleMatter':
          return '${value.toStringAsFixed(1)} µg/m³';
        default:
          return value.toString();
      }
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else {
      content = Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Diary Entry Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black),
                  onPressed: () {
                    // Edit functionality could be added later
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit functionality coming soon')),
                    );
                  },
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _buildMainContent(),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.00, -1.00),
            end: Alignment(0, 1),
            colors: [Color(0xFFEBC5FF), Color(0xAA9ADAD5), Color(0xFF957AA3)],
          ),
        ),
        child: SafeArea(child: content),
      ),
    );
  }

  Widget _buildMainContent() {
    List<Widget> contentWidgets = [];

    // Date & Time
    if (_entryData.containsKey('timestamp') && _entryData['timestamp'] != null) {
      contentWidgets.add(
        _buildInfoCard(
          'Date & Time',
          DateFormat('EEEE, MMMM d, yyyy - h:mm a')
              .format((_entryData['timestamp'] as Timestamp).toDate()),
          const Color(0xFF9866B0),
          Icons.calendar_today,
        ),
      );
      contentWidgets.add(const SizedBox(height: 16));
    }

    // Mood
    if (_entryData.containsKey('mood') && _entryData['mood'] != null) {
      contentWidgets.add(
        _buildInfoCard(
          'Mood',
          _getMoodEmoji(_entryData['mood']),
          Colors.amber,
          Icons.emoji_emotions,
        ),
      );
      contentWidgets.add(const SizedBox(height: 16));
    }

    // Diary Text
    if (_entryData.containsKey('text') &&
        _entryData['text'] != null &&
        _entryData['text'].toString().isNotEmpty) {
      contentWidgets.add(
        _buildSection(
          'Diary Entry',
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _entryData['text'].toString(),
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ),
      );
      contentWidgets.add(const SizedBox(height: 16));
    }

    // Entities
    if (_entryData.containsKey('nerResults') && _entryData['nerResults'] != null) {
      final nerResults = _entryData['nerResults'] as Map<String, dynamic>;
      final entities = nerResults['entities'] as List<dynamic>? ?? [];
      if (entities.isNotEmpty) {
        contentWidgets.add(
          _buildSection(
            'Detected Entities',
            child: Column(
              children: _buildEntityGroups(entities),
            ),
          ),
        );
        contentWidgets.add(const SizedBox(height: 16));
      }
    }

    // Selected Symptoms
    if (_entryData.containsKey('symptoms') && _entryData['symptoms'] != null) {
      final symptoms = _entryData['symptoms'] as Map<String, dynamic>;
      final selectedSymptoms = symptoms.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toList();

      if (selectedSymptoms.isNotEmpty) {
        contentWidgets.add(
          _buildSection(
            'Selected Symptoms',
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedSymptoms.map((symptom) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      symptom,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
        contentWidgets.add(const SizedBox(height: 16));
      }
    }

    // Environmental Data
    if (_entryData.containsKey('environmentalData') &&
        _entryData['environmentalData'] != null) {
      final envData = _entryData['environmentalData'] as Map<String, dynamic>;
      if (envData.isNotEmpty) {
        List<Widget> envWidgets = [];
        for (var entry in envData.entries) {
          envWidgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatFieldName(entry.key),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatEnvironmentalValue(entry.key, entry.value),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        contentWidgets.add(
          _buildSection(
            'Environmental Data',
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: envWidgets),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contentWidgets,
    );
  }

  // Get emoji based on mood index
  String _getMoodEmoji(int moodIndex) {
    switch (moodIndex) {
      case 0:
        return '😄 Happy';
      case 1:
        return '🙂 Good';
      case 2:
        return '😐 Neutral';
      case 3:
        return '😞 Sad';
      default:
        return 'Unknown';
    }
  }

  // Build a simple info card
  Widget _buildInfoCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build a section with title
  Widget _buildSection(String title, {required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF9866B0).withAlpha(26),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9866B0),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  // Group entities by type for display
  List<Widget> _buildEntityGroups(List<dynamic> entities) {
    // Group entities by type
    final groupedEntities = <String, List<Map<String, dynamic>>>{};

    for (var entity in entities) {
      final type = entity['type'] as String? ?? '';
      if (!groupedEntities.containsKey(type)) {
        groupedEntities[type] = [];
      }
      groupedEntities[type]!.add(entity as Map<String, dynamic>);
    }

    // Build sections for each group
    final sections = <Widget>[];

    final displayOrder = [
      'SYMPTOM',
      'FOOD_TRIGGER',
      'ENVIRONMENT_TRIGGER',
      'ACTIVITY_TRIGGER',
      'MEDICATION',
      'PLACE',
      'TIME',
    ];

    // Add entities in the display order
    for (var type in displayOrder) {
      if (groupedEntities.containsKey(type)) {
        sections.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getEntityGroupTitle(type),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getEntityColor(type),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _buildEntityItems(groupedEntities[type]!, type),
                ),
              ],
            ),
          ),
        );
      }
    }

    // Add any remaining entity types not in the display order
    for (var type in groupedEntities.keys) {
      if (!displayOrder.contains(type)) {
        sections.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getEntityGroupTitle(type),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getEntityColor(type),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _buildEntityItems(groupedEntities[type]!, type),
                ),
              ],
            ),
          ),
        );
      }
    }

    if (sections.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No entities detected'),
          ),
        ),
      ];
    }

    return sections;
  }

  // Build entity items for a specific type
  List<Widget> _buildEntityItems(List<Map<String, dynamic>> entities, String type) {
    return entities.map((entity) {
      final text = entity['text'] as String? ?? '';
      final confidence = entity['confidence'] as double? ?? 0.0;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _getEntityColor(type).withAlpha(50),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getEntityIcon(type),
              size: 16,
              color: _getEntityColor(type),
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: _getEntityColor(type),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (confidence > 0) ...[
              const SizedBox(width: 4),
              Text(
                '(${(confidence * 100).round()}%)',
                style: TextStyle(
                  color: _getEntityColor(type).withAlpha(179),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      );
    }).toList();
  }

  // Get a display title for entity groups
  String _getEntityGroupTitle(String type) {
    switch (type) {
      case 'SYMPTOM':
        return 'Symptoms';
      case 'FOOD_TRIGGER':
        return 'Food Triggers';
      case 'PLACE':
        return 'Places';
      case 'ENVIRONMENT_TRIGGER':
        return 'Environmental Triggers';
      case 'ACTIVITY_TRIGGER':
        return 'Activity Triggers';
      case 'MEDICATION':
        return 'Medications';
      case 'TIME':
        return 'Times';
      default:
        return _formatFieldName(type);
    }
  }
}

// Extension to capitalize first letter of string
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}