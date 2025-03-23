import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:permission_handler/permission_handler.dart';

class LogSymptomsScreen extends StatefulWidget {
  const LogSymptomsScreen({super.key});

  @override
  State<LogSymptomsScreen> createState() => _LogSymptomsScreenState();
}

class _LogSymptomsScreenState extends State<LogSymptomsScreen> with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final _thoughtsController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int? _selectedMoodIndex;
  bool _isLoading = false;

  // Speech to text variables
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  // Animation controller for mic button
  late AnimationController _animationController;
  bool _isAnimationInitialized = false;

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
  void initState() {
    super.initState();

    // Initialize the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationController.repeat();
    _isAnimationInitialized = true;

    // Request microphone permissions before initializing speech
    _requestPermissions();
  }

  // Listeners for speech recognition
  void errorListener(error) {
    debugPrint("Speech error: $error");
    if (mounted) {
      setState(() => _isListening = false);

      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Speech recognition error: $error'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void statusListener(String status) {
    debugPrint("Speech status: $status");
    if (mounted) {
      setState(() {
        _isListening = status == 'listening';
      });
    }
  }

  // Request necessary permissions
  Future<void> _requestPermissions() async {
    try {
      final status = await Permission.microphone.request();

      if (status.isGranted) {
        // Permission granted, initialize speech
        _initSpeech();
      } else {
        // Permission denied
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission is required for speech recognition'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error requesting permissions: $e");
      // Try initializing anyway as a fallback
      _initSpeech();
    }
  }

  // Initialize speech to text
  void _initSpeech() async {
    try {
      // Use the requested initialization approach with options parameter
      var hasSpeech = await _speech.initialize(
          onError: errorListener,
          onStatus: statusListener,
          debugLogging: true,
          options: [stt.SpeechToText.androidIntentLookup]
      );

      if (hasSpeech) {
        debugPrint("Speech recognition available");

        // Get available locales for debugging
        final locales = await _speech.locales();
        debugPrint("Available locales: ${locales.map((e) => e.localeId).join(', ')}");
      } else {
        debugPrint("Speech recognition not available");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Speech recognition is not available on your device. You can still type your symptoms.'),
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error initializing speech: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing speech: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Listen for speech and convert to text
  void _startListening() async {
    if (!_isListening) {
      try {
        // Reinitialize for consistency
        var hasSpeech = await _speech.initialize(
            onError: errorListener,
            onStatus: statusListener,
            debugLogging: true,
            options: [stt.SpeechToText.androidIntentLookup]
        );

        if (hasSpeech) {
          setState(() => _isListening = true);
          debugPrint("Starting to listen...");

          await _speech.listen(
            onResult: _onSpeechResult,
            listenFor: const Duration(minutes: 5), // Longer duration for real usage
            pauseFor: const Duration(seconds: 10),
            partialResults: true,
            listenMode: stt.ListenMode.confirmation,
          );
          debugPrint("Listen method completed successfully");
        } else {
          debugPrint("Speech recognition not available");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Speech recognition is not available on your device. Please type instead.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        debugPrint("Error in speech listen: $e");
        if (mounted) {
          setState(() => _isListening = false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Speech recognition error: $e'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  // Stop listening
  void _stopListening() async {
    if (_isListening) {
      setState(() => _isListening = false);
      await _speech.stop();
    }
  }

  // Handle speech result
  void _onSpeechResult(SpeechRecognitionResult result) {
    debugPrint("Speech result: ${result.recognizedWords}, final: ${result.finalResult}");

    if (mounted) {
      setState(() {
        if (result.recognizedWords.isNotEmpty) {
          // Store the current text
          final String existingText = _thoughtsController.text;

          if (result.finalResult) {
            // For final results, append to existing text with proper spacing
            if (existingText.isNotEmpty && !existingText.endsWith(' ')) {
              _thoughtsController.text = "$existingText ${result.recognizedWords}";
            } else {
              _thoughtsController.text = existingText + result.recognizedWords;
            }
          } else {
            // For partial results, if we have no text yet, show the partial result
            if (existingText.isEmpty) {
              _thoughtsController.text = result.recognizedWords;
            }
          }

          // Ensure cursor is at the end after updating text
          _thoughtsController.selection = TextSelection.fromPosition(
            TextPosition(offset: _thoughtsController.text.length),
          );
        }
      });
    }
  }

  // Create a pulsating mic icon for the listening animation
  Widget _buildPulsatingMicIcon() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Icon(
          Icons.mic,
          color: Colors.white,
          size: 24 + (_animationController.value * 4),
        );
      },
    );
  }

  @override
  void dispose() {
    _thoughtsController.dispose();
    _speech.cancel();

    // Prevent animation controller error
    if (_isAnimationInitialized) {
      _animationController.dispose();
    }

    super.dispose();
  }

  Future<void> _saveSymptoms() async {
    if (_selectedMoodIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your mood')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create symptoms map
      Map<String, bool> symptoms = {};
      for (int i = 0; i < _symptoms.length; i++) {
        symptoms[_symptoms[i]] = _selectedSymptoms[i];
      }

      // Save to Firestore
      await _firestoreService.logSymptoms(
        mood: _selectedMoodIndex!,
        thoughts: _thoughtsController.text,
        symptoms: symptoms,
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Symptoms logged successfully')),
      );

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving symptoms: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
              // Back Button and Save Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : _saveSymptoms,
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF9866B0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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
                                      ? _moods[index]['color'].withAlpha(51)
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

                      // Thoughts Section with Speech-to-Text
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
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              TextField(
                                controller: _thoughtsController,
                                maxLines: 6,
                                decoration: InputDecoration(
                                  hintText: _isListening
                                      ? 'Listening...'
                                      : 'Write your thoughts here...',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FloatingActionButton.small(
                                  onPressed: () {
                                    if (_isListening) {
                                      _stopListening();
                                    } else {
                                      _startListening();
                                    }
                                  },
                                  backgroundColor: _isListening ? Colors.red : const Color(0xFF9866B0),
                                  child: _isListening
                                      ? _buildPulsatingMicIcon()  // Use pulsating mic when listening
                                      : const Icon(
                                    Icons.mic,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              // Listening status indicator
                              if (_isListening)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withAlpha(51),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.purple.withAlpha(100)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.mic,
                                          size: 14,
                                          color: Colors.purple.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Listening...',
                                          style: TextStyle(
                                            color: Colors.purple.shade700,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
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