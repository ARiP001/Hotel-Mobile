import 'package:flutter/material.dart';
import 'package:TuruKamar/utilities/notification_service.dart';
import 'package:TuruKamar/pages/home_page.dart';
import 'package:TuruKamar/pages/welcome_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/transaction.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionAdapter());
  await NotificationService().initNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF388E3C),
          primary: Color(0xFF388E3C),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF388E3C), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF388E3C)),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF388E3C)),
          ),
        ),
      ),
      home: WelcomePage(),
    );
  }
}

Future<void> initNotification() async {
  // ... your existing code ...
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}
