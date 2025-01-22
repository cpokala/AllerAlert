import 'package:flutter/material.dart';

class LogSymptomsScreen extends StatefulWidget {
  const LogSymptomsScreen({super.key});

  @override
  State<LogSymptomsScreen> createState() => _LogSymptomsScreenState();
}

class _LogSymptomsScreenState extends State<LogSymptomsScreen> {
  final _thoughtsController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int? _selectedMoodIndex;

  final List<String> _symptoms = [
    'Coughing',
    'Wheezing',
    'Fatigue',
    'Increased mucus production'
  ];
  final List<bool> _selectedSymptoms = [false, false, false, false];

  // Define emoji data
  final List<Map<String, dynamic>> _moods = [
    {
      'emoji': '😄',
      'color': Colors.yellow,
    },
    {
      'emoji': '🙂',
      'color': Colors.yellow,
    },
    {
      'emoji': '😐',
      'color': Colors.yellow,
    },
    {
      'emoji': '😞',
      'color': Colors.yellow,
    },
  ];

  @override
  void dispose() {
    _thoughtsController.dispose();
    super.dispose();
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
              // Back Button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Mood Section
                      _buildSection(
                        'How was your day?',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(4, (index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedMoodIndex = index;
                                });
                              },
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _selectedMoodIndex == index
                                      ? _moods[index]['color'].withOpacity(0.2)
                                      : Colors.transparent,
                                ),
                                child: Center(
                                  child: Text(
                                    _moods[index]['emoji'],
                                    style: const TextStyle(
                                      fontSize: 40,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Date and Time Section
                      _buildSection(
                        'Date and Time',
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_selectedDate.toLocal()}'.split(' ')[0],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2025),
                                  );
                                  if (picked != null && picked != _selectedDate) {
                                    setState(() {
                                      _selectedDate = picked;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Thoughts Section
                      _buildSection(
                        'Tell us about your day',
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _thoughtsController,
                            maxLines: 6,
                            decoration: const InputDecoration(
                              hintText: 'Write your thoughts here...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Symptoms Section
                      _buildSection(
                        'Symptoms',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(_symptoms.length, (index) {
                            return ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedSymptoms[index] = !_selectedSymptoms[index];
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedSymptoms[index]
                                    ? const Color(0xFF9866B0)
                                    : Colors.white,
                                foregroundColor: _selectedSymptoms[index]
                                    ? Colors.white
                                    : const Color(0xFF9866B0),
                                elevation: 2,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: const Color(0xFF9866B0),
                                    width: _selectedSymptoms[index] ? 0 : 1,
                                  ),
                                ),
                              ),
                              child: Text(
                                _symptoms[index],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedSymptoms[index]
                                      ? Colors.white
                                      : const Color(0xFF9866B0),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}