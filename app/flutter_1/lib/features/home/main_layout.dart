import 'package:flutter/material.dart';
import 'package:flutter_1/features/home/home_page.dart';
import 'package:flutter_1/features/groups/pages/groups_page.dart';
import 'package:flutter_1/features/subscriptions/pages/subscriptions_page.dart';
import 'package:flutter_1/features/activity/pages/activity_page.dart';
import 'package:flutter_1/features/profile/pages/profile_page.dart';
import 'widgets/bottom_navigation.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const GroupsPage(),
    const SubscriptionsPage(),
    const ActivityPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Stack(
        children: [
          // Current Page
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          
          // Floating Bottom Navigation
          BottomNavigation(
            selectedIndex: _selectedIndex,
            onItemSelected: _onItemTapped,
          ),
        ],
      ),
    );
  }
}
