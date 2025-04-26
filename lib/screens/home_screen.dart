import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final user = firebase_auth.FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.00, -1.00),
            end: Alignment(0, 1),
            colors: [Color(0xFFEBC5FF), Color(0xAA9ADAD5), Color(0xFF957AA3)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Greeting Card
                _buildGreetingCard(user),

                const SizedBox(height: 20),

                // Action Buttons
                _buildActionButtons(context),

                const SizedBox(height: 20),

                // Main Cards - Use Expanded to distribute remaining space
                Expanded(
                  child: Column(
                    children: [
                      // Air Quality Card
                      Expanded(
                        flex: 3,
                        child: _buildAirQualityCard(context),
                      ),

                      const SizedBox(height: 12),

                      // Community Card - fixed to be centered and proper size
                      Expanded(
                        flex: 2,
                        child: _buildCommunityCard(context),
                      ),

                      const SizedBox(height: 12),

                      // Asthma History Card - fixed to be centered
                      Expanded(
                        flex: 2,
                        child: _buildAsthmaHistoryCard(context),
                      ),

                      // Add some space at the bottom
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingCard(firebase_auth.User? user) {
    final String displayName = user?.displayName?.split(' ')[0] ?? 'there';
    final String? photoURL = user?.photoURL;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, $displayName',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'How have you been?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF9866B0),
            child: photoURL != null
                ? ClipOval(
              child: Image.network(
                photoURL,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            )
                : const Icon(Icons.person, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.medical_information,
          label: 'Symptoms',
          onTap: () => Navigator.pushNamed(context, '/log-symptoms'),
        ),
        _buildActionButton(
          icon: Icons.insights,
          label: 'Insights',
          onTap: () => Navigator.pushNamed(context, '/scan-devices'),
        ),
        _buildActionButton(
          icon: Icons.medication,
          label: 'Medication',
          onTap: () => Navigator.pushNamed(context, '/medications'),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: IconButton(
            icon: Icon(icon),
            onPressed: onTap,
            color: const Color(0xFF9866B0),
            iconSize: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAirQualityCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/air-quality'),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.asset(
                'assets/images/city_skyline.png',
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Check Air Quality',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Monitor local air quality in real-time',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/community'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF9866B0).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_alt_rounded,
                size: 30,
                color: Color(0xFF9866B0),
              ),
            ),
            const SizedBox(height: 10),
            const Column(
              children: [
                Text(
                  'Join Community',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Connect with others',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAsthmaHistoryCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Look at your Asthma History',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to DiaryInsightsScreen
                Get.toNamed('/diary-insights');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9866B0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Check your Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}