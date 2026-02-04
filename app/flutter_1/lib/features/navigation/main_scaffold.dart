import 'package:flutter/material.dart';
import 'package:flutter_1/features/activity/pages/activity_page.dart';
import 'package:flutter_1/features/groups/pages/groups_page.dart';
import 'package:flutter_1/features/home/home_page.dart';
import 'package:flutter_1/features/profile/pages/profile_page.dart';
import 'package:flutter_1/features/subscriptions/pages/subscriptions_page.dart';
import 'package:flutter_1/features/home/widgets/bottom_navigation.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  } 

  void _onNavTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            physics: const BouncingScrollPhysics(),
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: [
              HomePage(),
              GroupsPage(),
              SubscriptionsPage(),
              ActivityPage(),
              ProfilePage(),
            ],
          ),
          BottomNavigation(
            selectedIndex: _currentIndex,
            onItemSelected: _onNavTap,
          ),
        ],
      ),
    );
  }
}
