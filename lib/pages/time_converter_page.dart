import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:async';

class TimeConverterPage extends StatefulWidget {
  const TimeConverterPage({super.key});

  @override
  State<TimeConverterPage> createState() => _TimeConverterPageState();
}

class _TimeConverterPageState extends State<TimeConverterPage> {
  final TextEditingController _wibController = TextEditingController();
  final TextEditingController _witaController = TextEditingController();
  final TextEditingController _witController = TextEditingController();
  final TextEditingController _londonController = TextEditingController();
  
  DateTime _currentTime = DateTime.now();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _wibController.dispose();
    _witaController.dispose();
    _witController.dispose();
    _londonController.dispose();
    super.dispose();
  }

  void _convertFromWIB(String time) {
    if (time.isEmpty) {
      _clearAllFields();
      return;
    }

    try {
      // Parse WIB time
      final wibTime = DateFormat('HH:mm').parse(time);
      final now = DateTime.now();
      final dateTime = DateTime(
        now.year,
        now.month,
        now.day,
        wibTime.hour,
        wibTime.minute,
      );

      // Convert to other time zones
      final witaTime = dateTime.add(const Duration(hours: 1));
      final witTime = dateTime.add(const Duration(hours: 2));
      final londonTime = dateTime.subtract(const Duration(hours: 6));

      setState(() {
        _witaController.text = DateFormat('HH:mm').format(witaTime);
        _witController.text = DateFormat('HH:mm').format(witTime);
        _londonController.text = DateFormat('HH:mm').format(londonTime);
      });
    } catch (e) {
      _clearAllFields();
    }
  }

  void _convertFromWITA(String time) {
    if (time.isEmpty) {
      _clearAllFields();
      return;
    }

    try {
      // Parse WITA time
      final witaTime = DateFormat('HH:mm').parse(time);
      final now = DateTime.now();
      final dateTime = DateTime(
        now.year,
        now.month,
        now.day,
        witaTime.hour,
        witaTime.minute,
      );

      // Convert to other time zones
      final wibTime = dateTime.subtract(const Duration(hours: 1));
      final witTime = dateTime.add(const Duration(hours: 1));
      final londonTime = dateTime.subtract(const Duration(hours: 7));

      setState(() {
        _wibController.text = DateFormat('HH:mm').format(wibTime);
        _witController.text = DateFormat('HH:mm').format(witTime);
        _londonController.text = DateFormat('HH:mm').format(londonTime);
      });
    } catch (e) {
      _clearAllFields();
    }
  }

  void _convertFromWIT(String time) {
    if (time.isEmpty) {
      _clearAllFields();
      return;
    }

    try {
      // Parse WIT time
      final witTime = DateFormat('HH:mm').parse(time);
      final now = DateTime.now();
      final dateTime = DateTime(
        now.year,
        now.month,
        now.day,
        witTime.hour,
        witTime.minute,
      );

      // Convert to other time zones
      final wibTime = dateTime.subtract(const Duration(hours: 2));
      final witaTime = dateTime.subtract(const Duration(hours: 1));
      final londonTime = dateTime.subtract(const Duration(hours: 8));

      setState(() {
        _wibController.text = DateFormat('HH:mm').format(wibTime);
        _witaController.text = DateFormat('HH:mm').format(witaTime);
        _londonController.text = DateFormat('HH:mm').format(londonTime);
      });
    } catch (e) {
      _clearAllFields();
    }
  }

  void _convertFromLondon(String time) {
    if (time.isEmpty) {
      _clearAllFields();
      return;
    }

    try {
      // Parse London time
      final londonTime = DateFormat('HH:mm').parse(time);
      final now = DateTime.now();
      final dateTime = DateTime(
        now.year,
        now.month,
        now.day,
        londonTime.hour,
        londonTime.minute,
      );

      // Convert to other time zones
      final wibTime = dateTime.add(const Duration(hours: 6));
      final witaTime = dateTime.add(const Duration(hours: 7));
      final witTime = dateTime.add(const Duration(hours: 8));

      setState(() {
        _wibController.text = DateFormat('HH:mm').format(wibTime);
        _witaController.text = DateFormat('HH:mm').format(witaTime);
        _witController.text = DateFormat('HH:mm').format(witTime);
      });
    } catch (e) {
      _clearAllFields();
    }
  }

  void _clearAllFields() {
    setState(() {
      _wibController.clear();
      _witaController.clear();
      _witController.clear();
      _londonController.clear();
    });
  }

  Widget _buildTimeInput({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
    required String currentTime,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Waktu saat ini: $currentTime',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Masukkan waktu (HH:mm)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    _clearAllFields();
                  },
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi Waktu'),
        backgroundColor: const Color(0xFF388E3C),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTimeInput(
              label: 'WIB (Jakarta)',
              controller: _wibController,
              onChanged: _convertFromWIB,
              currentTime: DateFormat('HH:mm').format(_currentTime),
            ),
            _buildTimeInput(
              label: 'WITA (Bali)',
              controller: _witaController,
              onChanged: _convertFromWITA,
              currentTime: DateFormat('HH:mm').format(_currentTime.add(const Duration(hours: 1))),
            ),
            _buildTimeInput(
              label: 'WIT (Papua)',
              controller: _witController,
              onChanged: _convertFromWIT,
              currentTime: DateFormat('HH:mm').format(_currentTime.add(const Duration(hours: 2))),
            ),
            _buildTimeInput(
              label: 'London',
              controller: _londonController,
              onChanged: _convertFromLondon,
              currentTime: DateFormat('HH:mm').format(_currentTime.subtract(const Duration(hours: 6))),
            ),
          ],
        ),
      ),
    );
  }
} 