import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/log_symptoms_screen.dart';
import 'screens/medications_screen.dart';
import 'screens/community_screen.dart';
import 'screens/air_quality_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Bluetooth/ble_controller.dart';
import 'Bluetooth/device_data_screen.dart';
import 'Bluetooth/ml_service.dart';
import 'services/firestore_service.dart';
import 'screens/diary_insights_screen.dart';
import 'screens/diary_entry_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) {
      print('Firebase initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Failed to initialize Firebase: $e');
    }
  }

  // Initialize Service - only FirestoreService since there's no FirebaseService
  Get.put(FirestoreService());

  // Request permissions
  await requestPermissions();

  // Initialize ML Service
  try {
    await MlService.initialize();
    if (kDebugMode) {
      print('ML Service initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Failed to initialize ML Service: $e');
    }
  }

  runApp(const MyApp());
}

// Function to request required permissions
Future<void> requestPermissions() async {
  // Request microphone permission
  final micStatus = await Permission.microphone.request();
  if (kDebugMode) {
    print('Microphone permission status: $micStatus');
  }

  // Request Bluetooth permissions
  final bluetoothScan = await Permission.bluetoothScan.request();
  final bluetoothConnect = await Permission.bluetoothConnect.request();
  final bluetooth = await Permission.bluetooth.request();
  final location = await Permission.location.request();

  if (kDebugMode) {
    print('Bluetooth scan permission: $bluetoothScan');
    print('Bluetooth connect permission: $bluetoothConnect');
    print('Bluetooth permission: $bluetooth');
    print('Location permission: $location');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the Get controller for BLE
    Get.put(BleController());

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AllerAlert',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          headlineMedium: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          bodyLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const LoginScreen()),
        GetPage(name: '/signup', page: () => const SignupScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/log-symptoms', page: () => const LogSymptomsScreen()),
        GetPage(name: '/medications', page: () => const MedicationsScreen()),
        GetPage(name: '/community', page: () => const CommunityScreen()),
        GetPage(name: '/air-quality', page: () => const AirQualityScreen()),
        GetPage(name: '/diary-insights', page: () => const DiaryInsightsScreen()),
        GetPage(
          name: '/insights',
          page: () => DeviceDataScreen(
            controller: Get.find<BleController>(),
          ),
        ),
        GetPage(
          name: '/scan-devices',
          page: () => BluetoothScanScreen(),
        ),
      ],
    );
  }
}

// New screen to scan for Bluetooth devices before showing the insights
class BluetoothScanScreen extends StatelessWidget {
  final BleController controller = Get.find<BleController>();

  BluetoothScanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connect to Air Monitor"),
        backgroundColor: const Color(0xFF9866B0),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.00, -1.00),
            end: Alignment(0, 1),
            colors: [Color(0xFFEBC5FF), Color(0xAA9ADAD5), Color(0xFF957AA3)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Please connect to your personal air quality monitor to track your environment",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ScanResult>>(
                stream: controller.scanResults,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final data = snapshot.data![index];
                        // Changed from name to platformName to fix deprecation warning
                        final deviceName = data.device.platformName.isNotEmpty
                            ? data.device.platformName
                            : "Unknown Device";

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.bluetooth,
                              color: Color(0xFF9866B0),
                            ),
                            title: Text(
                              deviceName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("Signal: ${data.rssi} dBm"),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              controller.connectToDevice(data.device, context);
                              Get.toNamed('/insights');
                            },
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "No devices found.\nTap SCAN to search for your air quality monitor.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Obx(() => controller.isScanning.value
                  ? const CircularProgressIndicator(
                color: Color(0xFF9866B0),
              )
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.scanDevices();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9866B0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "SCAN FOR DEVICES",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}