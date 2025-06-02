import 'package:flutter/material.dart';
import 'package:proyek_akhir_teori/utilities/notification_service.dart';
import 'package:proyek_akhir_teori/pages/home_page.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

Future<void> initNotification() async {
  // ... your existing code ...
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}
