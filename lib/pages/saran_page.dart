import 'package:flutter/material.dart';
import 'welcome_page.dart';
import '../utils/session_manager.dart';

class SaranPage extends StatefulWidget {
  const SaranPage({super.key});

  @override
  State<SaranPage> createState() => _SaranPageState();
}

class _SaranPageState extends State<SaranPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> tabs = ['Saran', 'Kesan'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    await SessionManager.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomePage()),
      (route) => false,
    );
  }

  Widget _buildCustomTab(String title, bool isSelected) {
    return Container(
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
            duration: const Duration(milliseconds: 10),
            height: 3,
            width: 150,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color.fromARGB(255, 107, 224, 113)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            color: const Color(0xFF388E3C),
            child: AnimatedBuilder(
              animation: _tabController,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(tabs.length, (index) {
                    final isSelected = _tabController.index == index;
                    return GestureDetector(
                      onTap: () => _tabController.animateTo(index),
                      child: _buildCustomTab(tabs[index], isSelected),
                    );
                  }),
                );
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildContent(
                  "Saran",
                  'Praktikum teknologi pemrograman mobile ini sangat menarik dan menyenangkan. '
                  'Saya merasa terbantu dengan bimbingan dari Bang Dejan dan Bang Azkal selama proses pembelajaran.',
                ),
                _buildContent(
                  "Kesan",
                  'Praktikum ini memberikan pengalaman belajar yang menyenangkan dan bermanfaat. '
                  'Bang Dejan dan Bang Azkal sangat membantu dan sabar dalam membimbing selama praktikum.',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hal yang dapat saya sampaikan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              Text(
                content,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 