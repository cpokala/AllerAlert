import 'package:flutter/material.dart';

class MedicationsScreen extends StatelessWidget {
  const MedicationsScreen({super.key});

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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Medication Schedule Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF957AA3),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Medication Schedule',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Stay on track with your treatments',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.alarm_add, color: Colors.black),
                        label: const Text(
                          'Set a New Reminder',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD9D9D9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        onPressed: () {
                          // TODO: Implement reminder setting
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Today's Medication Section
                _buildSection(
                  "Today's Medication",
                child: Column(
                children: [
                  _buildMedicationItem(
                  'Albuterol Inhaler',
                  '2 puffs, every 4-6 hours',
                  showTakeNow: true,
                ),
                const SizedBox(height: 16),
                _buildMedicationItem(
                  'Montelukast',
                  '10 mg, before bedtime',
                  showTakeNow: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Medication History Section
          _buildSection(
            'Medication History',
            child: Column(
              children: [
                _buildHistoryItem(
                  'Albuterol Inhaler',
                  'Taken at 8:30 am',
                  true,
                ),
                const SizedBox(height: 16),
                _buildHistoryItem(
                  'Fluticasone Nasal Spray',
                  'Taken at 9 am',
                  true,
                ),
                const SizedBox(height: 16),
                _buildHistoryItem(
                  'Montelukast',
                  'Missed at 10 pm',
                  false,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // All Medications Section
          _buildSection(
            'All Medications',
            child: Column(
              children: [
                _buildAllMedicationsItem(
                  'Albuterol Inhaler',
                  'For quick relief of asthma symptoms',
                ),
                const SizedBox(height: 16),
                _buildAllMedicationsItem(
                  'Montelukast',
                  'Daily for asthma control',
                ),
                const SizedBox(height: 16),
                _buildAllMedicationsItem(
                  'Fluticasone Nasal Spray',
                  'For allergic rhinitis',
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Add New Medication Button
          ElevatedButton(
            onPressed: () {
              // TODO: Implement add medication
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9866B0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.white),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              '+ Add New Medication Here',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildMedicationItem(String name, String dosage, {bool showTakeNow = false}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                dosage,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        if (showTakeNow)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF9866B0),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              'Take Now',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHistoryItem(String name, String time, bool taken) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: taken ? Colors.black : const Color(0xFFD81717),
                ),
              ),
            ],
          ),
        ),
        Icon(
          taken ? Icons.check_circle : Icons.error,
          color: taken ? Colors.green : const Color(0xFFD81717),
        ),
      ],
    );
  }

  Widget _buildAllMedicationsItem(String name, String description) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.edit),
      ],
    );
  }
}