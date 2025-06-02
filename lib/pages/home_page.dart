import 'package:flutter/material.dart';
import 'main_menu_page.dart';
import 'profil_page.dart';
import 'saran_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    MainMenuPage(),
    ProfilPage(),
    SaranPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isMainMenu = _currentIndex == 0;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 12,
        backgroundColor: const Color(0xFF388E3C),
        elevation: 1,
        title: Text(
          isMainMenu ? 'TuruKamar' : (_currentIndex == 1 ? 'Profil' : 'Saran & Kesan'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: isMainMenu
            ? [
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.white),
                  onPressed: () {
                    // TODO: Implement notification page
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    // TODO: Implement search page
                  },
                ),
              ]
            : null,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.white,
        backgroundColor: const Color(0xFF388E3C),
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Saran'),
        ],
      ),
    );
  }
}