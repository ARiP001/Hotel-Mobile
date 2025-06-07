import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/session_manager.dart';
import '../utils/currency_util.dart';
import 'welcome_page.dart';
import 'bookmark_page.dart';
import 'tentang_page.dart';
import 'receipt_history_page.dart';
import 'topup_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  int _selectedTabIndex = 0;
  String? _username;
  String? _email;
  String? _region;
  String? _password;
  double? _balance;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _checkSession();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('logged_in_user');
    if (username != null) {
      final email = prefs.getString('user_${username}_email');
      final password = prefs.getString('user_${username}_password');
      final region = prefs.getString('user_${username}_region');
      final balance = prefs.getDouble('user_${username}_balance');

      print('Debug - Loading user data:');
      print('Username: $username');
      print('Email: $email');
      print('Password hash: $password');
      print('Region: $region');
      print('Balance: $balance');

      setState(() {
        _username = username;
        _email = email;
        _password = password;
        _region = region;
        _balance = balance;
      });
    }
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

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka link')),
      );
    }
  }

  String _formatBalance() {
    if (_balance == null) return '-';
    final converted = CurrencyUtil.convert(_balance!, _region ?? 'usd');
    return CurrencyUtil.format(converted, _region ?? 'usd');
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Widget _buildTabItem(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              height: 3,
              width: 150,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color.fromARGB(255, 82, 183, 87)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard({
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title diklik')),
              );
            },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required String imagePath,
    required String name,
    required String email,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 170,
            width: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF388E3C),
                width: 2,
              ),
            ),
            child: _profileImage != null
                ? ClipOval(
                    child: Image.file(
                      _profileImage!,
                      fit: BoxFit.cover,
                      width: 170,
                      height: 170,
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 100,
                    color: Color(0xFF388E3C),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        _buildInfoCard(
          icon: Icons.person,
          title: 'Username',
          subtitle: name,
        ),
        const SizedBox(height: 20),
        _buildInfoCard(
          icon: Icons.email,
          title: 'Email',
          subtitle: email,
        ),
        const SizedBox(height: 20),
        _buildInfoCard(
          icon: Icons.account_balance_wallet,
          title: 'Saldo',
          subtitle: _formatBalance(),
        ),
        const SizedBox(height: 20),
        _buildInfoCard(
          icon: Icons.language,
          title: 'Region',
          subtitle: _region?.toUpperCase() ?? '-',
        ),
        const SizedBox(height: 20),
        _buildInfoCard(
          icon: Icons.lock,
          title: 'Password Hash',
          subtitle: _password ?? '-',
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 30, color: const Color(0xFF388E3C)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Tab Menu
          Container(
            color: const Color(0xFF388E3C),
            child: Row(
              children: [
                Expanded(child: _buildTabItem('Profil Pengguna', 0)),
                Expanded(child: _buildTabItem('Tools', 1)),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),

          // Konten Tab
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                // Tab 1: Profil Pengguna
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildProfileCard(
                          imagePath: '',
                          name: _username ?? '',
                          email: _email ?? '',
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await SessionManager.logout();
                              if (mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const WelcomePage()),
                                  (route) => false,
                                );
                              }
                            },
                            icon: const Icon(Icons.logout, color: Colors.white),
                            label: const Text('LOGOUT', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tab 2: Tools
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fitur Aplikasi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            _buildToolCard(
                              icon: Icons.bookmark,
                              title: 'Bookmark',
                              color: Colors.blue,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const BookmarkPage(),
                                  ),
                                );
                              },
                            ),
                            _buildToolCard(
                              icon: Icons.monetization_on,
                              title: 'Top Up Saldo',
                              color: Colors.green,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TopUpPage(),
                                  ),
                                );
                              },
                            ),
                            _buildToolCard(
                              icon: Icons.article,
                              title: 'Resi Pemesanan',
                              color: Colors.orange,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ReceiptHistoryPage(),
                                  ),
                                );
                              },
                            ),
                            _buildToolCard(
                              icon: Icons.info,
                              title: 'Tentang',
                              color: Colors.purple,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TentangPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 