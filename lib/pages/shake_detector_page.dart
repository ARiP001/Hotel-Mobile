import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:TuruKamar/utils/notification_service.dart';
import '../utils/session_manager.dart';
import 'welcome_page.dart';

class ShakeDetectorPage extends StatefulWidget {
  const ShakeDetectorPage({super.key});

  @override
  State<ShakeDetectorPage> createState() => _ShakeDetectorPageState();
}

class _ShakeDetectorPageState extends State<ShakeDetectorPage> {
  final NotificationService _notificationService = NotificationService();
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  bool _isShakeDetected = false;
  DateTime? _lastShakeTime;
  
  // Threshold untuk mendeteksi shake
  static const double _shakeThreshold = 5.0;
  // Minimum waktu antara notifikasi (dalam detik)
  static const int _minTimeBetweenShakes = 3;

  @override
  void initState() {
    super.initState();
    _checkSession();
    _startShakeDetection();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkSession() async {
    final isLoggedIn = await SessionManager.isLoggedIn();
    if (!isLoggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
      );
    }
  }

  void _startShakeDetection() {
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      // Hitung total akselerasi
      double acceleration = (event.x * event.x + event.y * event.y + event.z * event.z) / 1000;
      
      // Cek apakah akselerasi melebihi threshold
      if (acceleration > _shakeThreshold) {
        _handleShake();
      }
    });
  }

  void _handleShake() {
    final now = DateTime.now();
    
    // Cek apakah sudah cukup waktu sejak shake terakhir
    if (_lastShakeTime == null || 
        now.difference(_lastShakeTime!).inSeconds >= _minTimeBetweenShakes) {
      setState(() {
        _isShakeDetected = true;
        _lastShakeTime = now;
      });

      // Kirim notifikasi
      _notificationService.showNotification(
        title: "Shake Terdeteksi!",
        body: "HP kamu baru saja di-shake!",
      );

      // Reset status setelah 1 detik
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isShakeDetected = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shake Detector'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone_android,
              size: 100,
              color: _isShakeDetected ? Colors.red : Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              _isShakeDetected ? 'Shake Terdeteksi!' : 'Shake HP kamu',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _isShakeDetected ? Colors.red : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Shake HP kamu untuk mendapatkan notifikasi',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 