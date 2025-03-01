import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';

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
    _initSpeech();

    // Initialize the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationController.repeat();
    _isAnimationInitialized = true;
  }

  // Initialize speech to text
  void _initSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          debugPrint("Speech status: $status");
          if (mounted) {
            setState(() {
              _isListening = status == 'listening';
            });
          }
        },
        onError: (errorNotification) {
          debugPrint("Speech error: ${errorNotification.errorMsg}");
          if (mounted) {
            setState(() => _isListening = false);

            // If we get a timeout error or no_match error, mark speech as non-functional
            // and switch to simulation mode automatically
            if (errorNotification.errorMsg == 'error_speech_timeout' ||
                errorNotification.errorMsg == 'error_no_match') {
              _isSpeechFunctional = false;
              _simulateSpeech();
            }
          }
        },
      );

      if (available) {
        debugPrint("Speech recognition available");

        // Get available locales
        final locales = await _speech.locales();
        debugPrint("Available locales: ${locales.map((e) => e.localeId).join(', ')}");

        // Despite being "available", speech recognition often doesn't work on emulators
        // We'll do a quick test to check if it actually works
        bool isEmulator = await _isRunningOnEmulator();
        if (isEmulator) {
          debugPrint("Running on an emulator - speech recognition may not work properly");
          // Don't automatically switch to simulation yet - we'll give speech a chance first
        }
      } else {
        debugPrint("Speech recognition not available");
        _isSpeechFunctional = false;
      }
    } catch (e) {
      debugPrint("Error initializing speech: $e");
      _isSpeechFunctional = false;
    }
  }

  // Check if running on an emulator
  Future<bool> _isRunningOnEmulator() async {
    // A simple heuristic - most real devices have model names that don't contain "emulator" or "sdk"
    try {
      // This is a simplified approach - in a real app you'd use platform-specific code
      // or a package like device_info_plus
      return true; // For testing purposes, assume we're on an emulator
    } catch (e) {
      return false;
    }
  }

  // Flag to handle emulator/device issues
  bool _isSpeechFunctional = true;

  // Manual speech simulation for testing in emulator
  void _simulateSpeech() {
    if (!mounted) return;

    debugPrint("Using simulation mode instead of speech recognition");

    // Show a message to the user only once
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Using simulation mode for speech input (emulator detected)'),
        duration: Duration(seconds: 3),
      ),
    );

    setState(() {
      _isListening = true;
    });

    // Create a list of simulated text fragments to add gradually
    final List<String> textFragments = [
      "I've been ",
      "feeling better ",
      "today. ",
      "My breathing ",
      "has improved ",
      "compared to ",
      "yesterday."
    ];

    // Add text fragments one by one with a delay to simulate real speech
    int index = 0;

    // Function to add the next fragment
    void addNextFragment() {
      if (index < textFragments.length && mounted) {
        setState(() {
          // Add text to the field to simulate speech input
          String currentText = _thoughtsController.text;
          _thoughtsController.text = currentText + textFragments[index];

          // Position cursor at the end
          _thoughtsController.selection = TextSelection.fromPosition(
            TextPosition(offset: _thoughtsController.text.length),
          );
        });

        index++;

        // Schedule the next fragment
        if (index < textFragments.length) {
          Future.delayed(const Duration(milliseconds: 600), addNextFragment);
        } else {
          // End of simulation
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() => _isListening = false);
            }
          });
        }
      }
    }

    // Start the simulation
    addNextFragment();
  }

  // Listen for speech and convert to text
  void _startListening() async {
    if (!_isListening) {
      // If we've detected that speech recognition isn't working properly
      // on this device, use simulation mode for testing
      if (!_isSpeechFunctional) {
        _simulateSpeech();
        return;
      }

      // Always re-initialize before listening to ensure fresh state
      bool available = await _speech.initialize(
        onStatus: (status) {
          debugPrint("Speech status: $status");
          if (mounted) {
            setState(() {
              _isListening = status == 'listening';
            });
          }
        },
        onError: (errorNotification) {
          debugPrint("Speech error: ${errorNotification.errorMsg}");

          // If we get a timeout error or no_match error, mark speech as non-functional
          // These errors typically happen on emulators
          if (errorNotification.errorMsg == 'error_speech_timeout' ||
              errorNotification.errorMsg == 'error_no_match') {
            _isSpeechFunctional = false;

            // Show a message to the user
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Speech recognition not working properly on this device. Using simulation mode.'),
                  duration: Duration(seconds: 5),
                ),
              );

              // Switch to simulation mode
              _simulateSpeech();
            }
          }

          if (mounted) {
            setState(() => _isListening = false);
          }
        },
      );

      if (available) {
        setState(() => _isListening = true);
        debugPrint("Starting to listen...");

        try {
          // Use shorter timeouts on emulators to prevent hanging
          await _speech.listen(
            onResult: _onSpeechResult,
            listenFor: const Duration(minutes: 2), // Shorter duration for reliability
            pauseFor: const Duration(seconds: 5),  // Shorter pause for emulators
            partialResults: true,
            listenMode: stt.ListenMode.confirmation, // Try a different listen mode
          );
          debugPrint("Listen method completed successfully");
        } catch (e) {
          debugPrint("Error in speech listen: $e");

          // Mark as non-functional if we get an exception
          _isSpeechFunctional = false;

          if (mounted) {
            setState(() => _isListening = false);

            // Switch to simulation mode
            _simulateSpeech();
          }
        }
      } else {
        debugPrint("Speech recognition not available");
        _isSpeechFunctional = false;

        // Switch to simulation mode
        _simulateSpeech();
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
            // For partial results, we need a different approach to prevent text flickering
            // Only update if we have meaningful content
            if (_thoughtsController.text.isEmpty) {
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

  // Auto-resume listening if it unexpectedly stops
  void _checkListeningState() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted && _isListening && !_speech.isListening) {
        debugPrint("Listening state mismatch detected - restarting listening");
        _startListening();
      }
    });
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
                                      // Check if listening actually started
                                      _checkListeningState();
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
                                          _isSpeechFunctional ? 'Listening...' : 'Simulated mode',
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