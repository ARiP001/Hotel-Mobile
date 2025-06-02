import 'package:flutter/material.dart';
import 'package:proyek_akhir_teori/utilities/notification_service.dart';
import 'package:proyek_akhir_teori/pages/tracking_page.dart';
import 'package:proyek_akhir_teori/pages/shake_detector_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                NotificationService().showNotification(
                  title: "Title",
                  body: "Body",
                );
              },
              child: const Text("Send Notification"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TrackingPage()),
                );
              },
              child: const Text("Open Location Tracker"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShakeDetectorPage()),
                );
              },
              child: const Text("Open Shake Detector"),
            ),
          ],
        ),
      ),
    );
  }
}