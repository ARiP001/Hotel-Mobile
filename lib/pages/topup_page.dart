import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';
import '../utils/notification_service.dart';
import '../utils/currency_util.dart';
import '../utils/session_manager.dart';
import 'welcome_page.dart';

class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key});

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  final _amountController = TextEditingController();
  String? _username;
  String? _region;
  double _currentBalance = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
    _loadUserData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _checkSession() async {
    if (!await SessionManager.isLoggedIn()) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomePage()),
        );
      }
    }
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('logged_in_user');
    _region = prefs.getString('user_${_username}_region') ?? 'usd';
    _currentBalance = prefs.getDouble('user_${_username}_balance') ?? 0.0;

    setState(() => _isLoading = false);
  }

  String _formatCurrency(double amount) {
    final converted = CurrencyUtil.convert(amount, _region ?? 'usd');
    return CurrencyUtil.format(converted, _region ?? 'usd');
  }

  Future<void> _showShakeConfirmationDialog(double inputAmount) async {
    // Convert input amount to USD if region is not USD
    final amountInUSD = CurrencyUtil.convertToUSD(inputAmount, _region ?? 'usd');
    
    bool isConfirmed = false;
    StreamSubscription<AccelerometerEvent>? _subscription;
    BuildContext? dialogContext;

    void onShake() async {
      if (isConfirmed) return;
      isConfirmed = true;
      _subscription?.cancel();
      if (dialogContext != null) {
        Navigator.of(dialogContext!).pop();
        await Future.delayed(const Duration(milliseconds: 200));
      }

      // Update balance in USD
      final prefs = await SharedPreferences.getInstance();
      final balanceKey = 'user_${_username}_balance';
      final newBalance = _currentBalance + amountInUSD;
      await prefs.setDouble(balanceKey, newBalance);

      // Show notification
      await NotificationService().showNotification(
        title: 'Top Up Berhasil',
        body: 'Saldo Anda telah ditambahkan sebesar $inputAmount',
      );

      // Update UI
      setState(() {
        _currentBalance = newBalance;
        _amountController.clear();
      });

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Top Up Berhasil'),
            content: Text('Saldo Anda sekarang: ${_formatCurrency(_currentBalance)}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }

    _subscription = accelerometerEvents.listen((event) {
      double acceleration = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      if (acceleration > 15) {
        onShake();
      }
    });

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        dialogContext = ctx;
        return AlertDialog(
          title: const Text('Konfirmasi Top Up'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.phone_android, size: 60, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                'Shake HP Anda untuk konfirmasi top up',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _subscription?.cancel();
                Navigator.pop(ctx);
              },
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
    _subscription?.cancel();
  }

  void _handleTopUp() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jumlah yang valid')),
      );
      return;
    }

    _showShakeConfirmationDialog(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Up Saldo'),
        backgroundColor: const Color(0xFF388E3C),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Saldo Saat Ini',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatCurrency(_currentBalance),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF388E3C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Jumlah Top Up',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Masukkan jumlah top up',
                      prefixText: '${_region?.toUpperCase() ?? 'USD'} ',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF388E3C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _handleTopUp,
                      child: const Text(
                        'Top Up',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 