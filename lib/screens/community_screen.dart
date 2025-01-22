import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

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
              children: [
                // Title
                const Text(
                  'Asthma Resources',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                // Latest Blogs Section
                _buildSection(
                  'Latest Blogs',
                  children: [
                    _buildListItem(
                      '10 Natural Remedies for Asthma Relief',
                      icon: Icons.article,
                      color: Colors.orange,
                    ),
                    _buildListItem(
                      'Understanding Asthma Triggers: A Comprehensive Guide',
                      icon: Icons.article,
                      color: Colors.orange,
                    ),
                    _buildListItem(
                      'Asthma-Friendly Diet: Foods to Embrace and Avoid',
                      icon: Icons.article,
                      color: Colors.orange,
                    ),
                    _buildButton('Read More'),
                  ],
                ),

                const SizedBox(height: 20),

                // Research Papers Section
                _buildSection(
                  'Research Papers',
                  children: [
                    _buildListItem(
                      'Efficacy of Biologic Therapies in Severe Asthma',
                      icon: Icons.science,
                      color: Colors.green,
                    ),
                    _buildListItem(
                      'Impact of Air Pollution on Asthma Exacerbations',
                      icon: Icons.science,
                      color: Colors.green,
                    ),
                    _buildListItem(
                      'Gene-Environment Interactions in Asthma Development',
                      icon: Icons.science,
                      color: Colors.green,
                    ),
                    _buildButton('View Papers'),
                  ],
                ),

                const SizedBox(height: 20),

                // News Articles Section
                _buildSection(
                  'News Articles',
                  children: [
                    _buildListItem(
                      'FDA Approves New Inhaler Technology for Asthma Patients',
                      icon: Icons.newspaper,
                      color: Colors.blue,
                    ),
                    _buildListItem(
                      'Climate Change Linked to Rising Asthma Rates',
                      icon: Icons.newspaper,
                      color: Colors.blue,
                    ),
                    _buildListItem(
                      'Asthma Awareness Month: Global Initiatives Announced',
                      icon: Icons.newspaper,
                      color: Colors.blue,
                    ),
                    _buildButton('More News'),
                  ],
                ),

                const SizedBox(height: 20),

                // New Drug Discoveries Section
                _buildSection(
                  'New Drug Discoveries',
                  children: [
                    _buildListItem(
                      'Novel Monoclonal Antibody Shows Promise in Severe Asthma',
                      icon: Icons.medication,
                      color: Colors.amber,
                    ),
                    _buildListItem(
                      'Dual-Action Bronchodilator Enters Phase III Trials',
                      icon: Icons.medication,
                      color: Colors.amber,
                    ),
                    _buildListItem(
                      'Innovative Inhaled Corticosteroid Formulation Developed',
                      icon: Icons.medication,
                      color: Colors.amber,
                    ),
                    _buildButton('Explore Treatments'),
                  ],
                ),

                const SizedBox(height: 20),

                // Social Media Groups Section
                _buildSection(
                  'Social Media Groups',
                  children: [
                    _buildListItem(
                      'Asthma Warriors Support Group',
                      icon: Icons.group,
                      color: Colors.pink,
                    ),
                    _buildListItem(
                      'Breathe Easy: Asthma Management Tips',
                      icon: Icons.group,
                      color: Colors.pink,
                    ),
                    _buildListItem(
                      'Parents of Asthmatic Children Network',
                      icon: Icons.group,
                      color: Colors.pink,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, {required List<Widget> children}) {
    return Container(
      width: double.infinity,
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
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListItem(String text, {required IconData icon, required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text) {
    return Center(
      child: Container(
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
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9866B0),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Colors.white),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}