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

  @override
  void dispose() {
    _thoughtsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.00, -1.00),
            end: Alignment(0, 1),
            colors: [Color(0xFFEBC5FF), Color(0xAA9ADAD5), Color(0xFF957AA3)],
          ),
        ),
        child: SafeArea(
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
                      final IconData iconData = index == 0
                          ? Icons.sentiment_very_satisfied
                          : index == 1
                          ? Icons.sentiment_satisfied
                          : index == 2
                          ? Icons.sentiment_neutral
                          : Icons.sentiment_dissatisfied;
                      return IconButton(
                        icon: Icon(
                          iconData,
                          size: 32,
                          color: _selectedMoodIndex == index
                              ? const Color(0xFF9866B0)
                              : Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedMoodIndex = index;
                          });
                        },
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
                      return FilterChip(
                        label: Text(
                          _symptoms[index],
                          style: TextStyle(
                            color: _selectedSymptoms[index]
                                ? Colors.white
                                : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected: _selectedSymptoms[index],
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedSymptoms[index] = selected;
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFF9866B0),
                        checkmarkColor: Colors.white,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Colors.white),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
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