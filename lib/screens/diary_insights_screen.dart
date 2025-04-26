import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/diary_service.dart';
import 'diary_entry_detail_screen.dart';

class DiaryInsightsScreen extends StatefulWidget {
  const DiaryInsightsScreen({super.key});

  @override
  State<DiaryInsightsScreen> createState() => _DiaryInsightsScreenState();
}

class _DiaryInsightsScreenState extends State<DiaryInsightsScreen> with SingleTickerProviderStateMixin {
  final DiaryService _diaryService = DiaryService();
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _diaryService.getEntityStatistics();
      setState(() {
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading diary insights: $e')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Get a list of sorted entries for a map
  List<MapEntry<String, int>> _getSortedEntries(Map<String, int> map) {
    final entries = map.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  // Build a card with entity count
  Widget _buildEntityCard(String text, int count, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count mentions',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build a section with title and entity cards
  Widget _buildSection(String title, Map<String, int> data, Color color) {
    final sortedEntries = _getSortedEntries(data);

    if (sortedEntries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No $title detected yet',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
          ),
          itemCount: sortedEntries.length > 6 ? 6 : sortedEntries.length,
          itemBuilder: (context, index) {
            final entry = sortedEntries[index];
            return _buildEntityCard(entry.key, entry.value, color);
          },
        ),
        if (sortedEntries.length > 6)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: TextButton(
                onPressed: () {
                  // Show all entries in a bottom sheet
                  _showAllEntries(title, sortedEntries, color);
                },
                style: TextButton.styleFrom(
                  foregroundColor: color,
                ),
                child: const Text('View all'),
              ),
            ),
          ),
      ],
    );
  }

  void _showAllEntries(String title, List<MapEntry<String, int>> entries, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return ListTile(
                        title: Text(entry.key),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${entry.value}',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'Diary Insights',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.black),
                      onPressed: _fetchStatistics,
                    ),
                  ],
                ),
              ),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: const Color(0xFF9866B0),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  tabs: const [
                    Tab(text: 'Insights'),
                    Tab(text: 'Entries'),
                    Tab(text: 'Timeline'),
                  ],
                ),
              ),

              // Tab Bar View
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Insights Tab
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // Symptoms Section
                          _buildSection(
                            'Top Symptoms',
                            _statistics['symptoms'] ?? {},
                            Colors.red,
                          ),

                          const Divider(),

                          // Food Triggers Section
                          _buildSection(
                            'Food Triggers',
                            _statistics['foodTriggers'] ?? {},
                            Colors.orange,
                          ),

                          const Divider(),

                          // Environmental Triggers Section
                          _buildSection(
                            'Environmental Triggers',
                            _statistics['environmentalTriggers'] ?? {},
                            Colors.green,
                          ),

                          const Divider(),

                          // Activity Triggers Section
                          _buildSection(
                            'Activity Triggers',
                            _statistics['activityTriggers'] ?? {},
                            Colors.blue,
                          ),

                          const Divider(),

                          // Medications Section
                          _buildSection(
                            'Medications',
                            _statistics['medications'] ?? {},
                            Colors.purple,
                          ),

                          const Divider(),

                          // Places Section
                          _buildSection(
                            'Places',
                            _statistics['places'] ?? {},
                            Colors.teal,
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                    // Entries Tab
                    StreamBuilder<QuerySnapshot>(
                      stream: _diaryService.getDiaryEntries(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        final docs = snapshot.data?.docs ?? [];

                        if (docs.isEmpty) {
                          return const Center(
                            child: Text('No diary entries yet'),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final text = data['text'] as String? ?? '';
                            final timestamp = data['timestamp'] as Timestamp?;
                            final date = timestamp?.toDate() ?? DateTime.now();
                            final formattedDate = DateFormat('MMM d, yyyy - h:mm a').format(date);

                            // Get entities
                            final nerResults = data['nerResults'] as Map<String, dynamic>? ?? {};
                            final entities = nerResults['entities'] as List<dynamic>? ?? [];

                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Get.to(() => DiaryEntryDetailScreen(entryId: doc.id));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        text,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (entities.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: List.generate(
                                            entities.length > 3 ? 3 : entities.length,
                                                (i) {
                                              final entity = entities[i] as Map<String, dynamic>;
                                              final type = entity['type'] as String? ?? '';
                                              final text = entity['text'] as String? ?? '';

                                              Color chipColor;
                                              switch (type) {
                                                case 'SYMPTOM':
                                                  chipColor = Colors.red;
                                                  break;
                                                case 'FOOD_TRIGGER':
                                                  chipColor = Colors.orange;
                                                  break;
                                                case 'PLACE':
                                                  chipColor = Colors.teal;
                                                  break;
                                                case 'ENVIRONMENT_TRIGGER':
                                                  chipColor = Colors.green;
                                                  break;
                                                case 'ACTIVITY_TRIGGER':
                                                  chipColor = Colors.blue;
                                                  break;
                                                case 'MEDICATION':
                                                  chipColor = Colors.purple;
                                                  break;
                                                case 'TIME':
                                                  chipColor = Colors.blueGrey;
                                                  break;
                                                default:
                                                  chipColor = Colors.grey;
                                              }

                                              return Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: chipColor.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  text,
                                                  style: TextStyle(
                                                    color: chipColor,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        if (entities.length > 3)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              '+${entities.length - 3} more',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),

                    // Timeline Tab
                    StreamBuilder<QuerySnapshot>(
                      stream: _diaryService.getDiaryEntries(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        final docs = snapshot.data?.docs ?? [];

                        if (docs.isEmpty) {
                          return const Center(
                            child: Text('No diary entries yet'),
                          );
                        }

                        // Group entries by day
                        final Map<String, List<DocumentSnapshot>> groupedEntries = {};
                        for (var doc in docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          final timestamp = data['timestamp'] as Timestamp?;
                          final date = timestamp?.toDate() ?? DateTime.now();
                          final dateKey = DateFormat('yyyy-MM-dd').format(date);

                          if (!groupedEntries.containsKey(dateKey)) {
                            groupedEntries[dateKey] = [];
                          }

                          groupedEntries[dateKey]!.add(doc);
                        }

                        // Sort dates
                        final sortedDates = groupedEntries.keys.toList()
                          ..sort((a, b) => b.compareTo(a));

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: sortedDates.length,
                          itemBuilder: (context, index) {
                            final dateKey = sortedDates[index];
                            final entries = groupedEntries[dateKey]!;
                            final date = DateTime.parse(dateKey);
                            final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(date);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ...entries.map((doc) {
                                  final data = doc.data() as Map<String, dynamic>;
                                  final text = data['text'] as String? ?? '';
                                  final timestamp = data['timestamp'] as Timestamp?;
                                  final time = timestamp?.toDate() ?? DateTime.now();
                                  final formattedTime = DateFormat('h:mm a').format(time);

                                  // Get entities
                                  final nerResults = data['nerResults'] as Map<String, dynamic>? ?? {};
                                  final entities = nerResults['entities'] as List<dynamic>? ?? [];

                                  return InkWell(
                                    onTap: () {
                                      Get.to(() => DiaryEntryDetailScreen(entryId: doc.id));
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 20, bottom: 16),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 5,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF9866B0).withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  formattedTime,
                                                  style: const TextStyle(
                                                    color: Color(0xFF9866B0),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const Spacer(),
                                              const Icon(
                                                Icons.arrow_forward_ios,
                                                size: 14,
                                                color: Colors.grey,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            text,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (entities.isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 6,
                                              children: List.generate(
                                                entities.length > 3 ? 3 : entities.length,
                                                    (i) {
                                                  final entity = entities[i] as Map<String, dynamic>;
                                                  final type = entity['type'] as String? ?? '';
                                                  final text = entity['text'] as String? ?? '';

                                                  Color chipColor;
                                                  IconData iconData;

                                                  switch (type) {
                                                    case 'SYMPTOM':
                                                      chipColor = Colors.red;
                                                      iconData = Icons.healing;
                                                      break;
                                                    case 'FOOD_TRIGGER':
                                                      chipColor = Colors.orange;
                                                      iconData = Icons.fastfood;
                                                      break;
                                                    case 'PLACE':
                                                      chipColor = Colors.teal;
                                                      iconData = Icons.place;
                                                      break;
                                                    case 'ENVIRONMENT_TRIGGER':
                                                      chipColor = Colors.green;
                                                      iconData = Icons.nature;
                                                      break;
                                                    case 'ACTIVITY_TRIGGER':
                                                      chipColor = Colors.blue;
                                                      iconData = Icons.directions_run;
                                                      break;
                                                    case 'MEDICATION':
                                                      chipColor = Colors.purple;
                                                      iconData = Icons.medication;
                                                      break;
                                                    case 'TIME':
                                                      chipColor = Colors.blueGrey;
                                                      iconData = Icons.access_time;
                                                      break;
                                                    default:
                                                      chipColor = Colors.grey;
                                                      iconData = Icons.label;
                                                  }

                                                  return Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: chipColor.withOpacity(0.2),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          iconData,
                                                          size: 12,
                                                          color: chipColor,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          text,
                                                          style: TextStyle(
                                                            color: chipColor,
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/log-symptoms');
        },
        backgroundColor: const Color(0xFF9866B0),
        child: const Icon(Icons.add),
      ),
    );
  }
}