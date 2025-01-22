import 'package:flutter/material.dart';

class AirQualityScreen extends StatelessWidget {
  const AirQualityScreen({super.key});

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Weather Image
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          width: double.infinity,
                          height: 293,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/weather.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // Weather Details Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9D9D9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Weather Details',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildWeatherDetail('Temperature', '72 F'),
                                  _buildWeatherDetail('Humidity', '65%'),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildWeatherDetail('Pressure', '1013 hPa'),
                                  _buildWeatherDetail('Wind Speed', '5 mph'),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Air Quality Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9D9D9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Air Quality',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'AQI',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    '42',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Air Quality Slider (non-interactive)
                              SizedBox(
                                height: 33,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 9,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF3BD5FF),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                    Container(
                                      width: 33,
                                      height: 33,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF3BD5FF),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Good',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // TODO: Implement detailed forecast
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF9866B0),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  child: const Text(
                                    'View Detailed Forecast',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}