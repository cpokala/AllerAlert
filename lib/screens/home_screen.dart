import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Greeting Card
                _buildGreetingCard(),

                const SizedBox(height: 20),

                // Action Buttons Row
                _buildActionButtonsRow(context),

                const SizedBox(height: 24),

                // City Image
                _buildImageContainer('assets/images/city_skyline.png'),

                const SizedBox(height: 24),

                // Air Quality Button
                Center(child: _buildButton(context, 'Air Quality', width: 116)),

                const SizedBox(height: 24),

                // Community Image
                _buildImageContainer('assets/images/community.png'),

                const SizedBox(height: 24),

                // Join Community Button
                Center(child: _buildButton(context, 'Join our Community', width: 185)),

                const SizedBox(height: 24),

                // Asthma History Text
                const Text(
                  'Look at your Asthma History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 24),

                // Progress Button
                Center(child: _buildButton(context, 'Check your Progress', width: 185)),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi,',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'How have you been?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildButton(context, 'Log Symptom'),
        _buildButton(context, 'Insights'),
        _buildButton(context, 'Medication'),
      ],
    );
  }

  Widget _buildImageContainer(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        imagePath,
        width: double.infinity,
        height: 190,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, {double? width}) {
    return Container(
      width: width ?? 110,
      height: 41,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (text == 'Log Symptom') {
            Navigator.pushNamed(context, '/log-symptoms');
          } else if (text == 'Medication') {
            Navigator.pushNamed(context, '/medications');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9866B0),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.white, width: 1),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}