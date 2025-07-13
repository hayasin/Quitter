import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:quitter/Assets/colors.dart';
import 'package:quitter/pages/graph_page.dart';
import 'package:quitter/pages/home_page.dart';
import 'package:quitter/pages/friend_progress_page.dart';
// import 'package:quitter/pages/settings_page.dart'; // <-- future settings page

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _page = 0; // Start at HomePage
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  // List of pages (you can replace with your real pages)
  final List<Widget> _pages = const [
    HomePage(),
    GraphPage(),
    FriendProgressPage(), 
    Center(child: Text("Secret Page :)", style: TextStyle(color: Colors.white, fontSize: 24)),), 
    Center(
      child: Text(
        "Settings Page",
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _page,
        backgroundColor: AppColors.background,
        color: AppColors.main_accent,
        animationDuration: const Duration(milliseconds: 400),
        items: const [
          Icon(Icons.home, size: 30),
          Icon(Icons.bar_chart, size: 30),
          Icon(Icons.emoji_events, size: 30),
          Icon(Icons.savings, size: 30), 
          Icon(Icons.settings, size: 30),
        ],
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_page],
      ),
    );
  }
}
