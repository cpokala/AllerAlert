import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _showAddMedicationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          'Add New Medication',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Medication Name',
                    labelStyle: TextStyle(fontSize: 14),
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  ),
                  style: const TextStyle(fontSize: 14),
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter medication name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Dosage (e.g., 2 puffs, 10mg)',
                    labelStyle: TextStyle(fontSize: 14),
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  ),
                  style: const TextStyle(fontSize: 14),
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter dosage' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _frequencyController,
                  decoration: const InputDecoration(
                    labelText: 'Frequency (e.g., every 4-6 hours)',
                    labelStyle: TextStyle(fontSize: 14),
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  ),
                  style: const TextStyle(fontSize: 14),
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter frequency' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    labelStyle: TextStyle(fontSize: 14),
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  ),
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () => _handleAddMedication(),
            child: const Text(
              'Add',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAddMedication() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _firestoreService.addMedication(
          name: _nameController.text,
          dosage: _dosageController.text,
          frequency: _frequencyController.text,
          description: _descriptionController.text,
        );

        if (!mounted) return;
        Navigator.pop(context);

        // Clear form
        _nameController.clear();
        _dosageController.clear();
        _frequencyController.clear();
        _descriptionController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication added successfully')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding medication: $e')),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
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
                      FutureBuilder<QuerySnapshot>(
                        future: _firestoreService.getMedications(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return _buildSection(
                              "Today's Medication",
                              child: const Text('Error loading medications'),
                            );
                          }

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return _buildSection(
                              "Today's Medication",
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          }

                          final medications = snapshot.data?.docs ?? [];

                          return _buildSection(
                            "Today's Medication",
                            child: Column(
                              children: medications.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                return Column(
                                  children: [
                                    _buildMedicationItem(
                                      data['name'] ?? '',
                                      '${data['dosage']}, ${data['frequency']}',
                                      showTakeNow: true,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                );
                              }).toList(),
                            ),
                          );
                        },
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
                      FutureBuilder<QuerySnapshot>(
                        future: _firestoreService.getMedications(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return _buildSection(
                              'All Medications',
                              child: const Text('Error loading medications'),
                            );
                          }

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return _buildSection(
                              'All Medications',
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          }

                          final medications = snapshot.data?.docs ?? [];

                          return _buildSection(
                            'All Medications',
                            child: Column(
                              children: medications.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                return Column(
                                  children: [
                                    _buildAllMedicationsItem(
                                      data['name'] ?? '',
                                      data['description'] ?? '',
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Add New Medication Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _showAddMedicationDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9866B0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Colors.white),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
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
            ],
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