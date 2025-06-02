import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome_page.dart';
import '../utilities/currency_util.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String? _username;
  String? _email;
  String? _password;
  String? _region;
  double? _balance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('logged_in_user');
    if (username != null) {
      setState(() {
        _username = username;
        _email = prefs.getString('user_${username}_email');
        _password = prefs.getString('user_${username}_password');
        _region = prefs.getString('user_${username}_region');
        _balance = prefs.getDouble('user_${username}_balance');
      });
    }
  }

  String _formatBalance() {
    if (_balance == null) return '-';
    final converted = CurrencyUtil.convert(_balance!, _region ?? 'usd');
    return CurrencyUtil.format(converted, _region ?? 'usd');
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    await prefs.remove('logged_in_user');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Profil Page', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 24),
            if (_username != null) ...[
              Text('Username: $_username', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Email: ${_email ?? '-'}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Password (hash): ${_password ?? '-'}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Region: ${_region ?? '-'}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Balance: ${_formatBalance()}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 32),
            ],
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
} 