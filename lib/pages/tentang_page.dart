import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TentangPage extends StatelessWidget {
  const TentangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tentang Aplikasi',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF388E3C),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              height: 170,
              width: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF388E3C),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/Arif.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Versi 1.0.0',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              icon: Icons.code,
              title: 'Dikembangkan oleh',
              subtitle: 'Arif Fathurrahman',
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              icon: Icons.email,
              title: 'Email',
              subtitle: 'support@turukamar.com',
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              icon: Icons.link,
              title: 'Website',
              subtitle: 'https://turukamar.com',
              onTap: () => _launchURL('https://turukamar.com'),
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              icon: Icons.camera_alt,
              title: 'Instagram',
              subtitle: '@turukamar',
              onTap: () => _launchURL('https://instagram.com/turukamar'),
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              icon: Icons.work,
              title: 'LinkedIn',
              subtitle: 'turukamar',
              onTap: () => _launchURL('https://www.linkedin.com/company/turukamar'),
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              icon: Icons.chat,
              title: 'WhatsApp',
              subtitle: '+62 812-3456-7890',
              onTap: () => _launchURL('https://wa.me/6281234567890'),
            ),
            const SizedBox(height: 30),
            const Text(
              '© 2025 TuruKamar. All rights reserved.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
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

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchEmail() async {
    final uri = Uri.parse('mailto:support@turukamar.com');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch email';
    }
  }
} 