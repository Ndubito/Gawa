import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 16,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () => onItemSelected(0),
                icon: Icon(
                  Icons.home_outlined,
                  color: selectedIndex == 0
                      ? const Color(0xFF4a9fd8)
                      : Colors.grey,
                ),
              ),
              IconButton(
                onPressed: () => onItemSelected(1),
                icon: Icon(
                  Icons.people_outline,
                  color: selectedIndex == 1
                      ? const Color(0xFF4a9fd8)
                      : Colors.grey,
                ),
              ),
              IconButton(
                onPressed: () => onItemSelected(2),
                icon: Icon(
                  Icons.shopping_bag_outlined,
                  color: selectedIndex == 2
                      ? const Color(0xFF4a9fd8)
                      : Colors.grey,
                ),
              ),
              IconButton(
                onPressed: () => onItemSelected(3),
                icon: Icon(
                  Icons.history, // Activity
                  color: selectedIndex == 3
                      ? const Color(0xFF4a9fd8)
                      : Colors.grey,
                ),
              ),
              IconButton(
                onPressed: () => onItemSelected(4),
                icon: Icon(
                  Icons.person_outline,
                  color: selectedIndex == 4
                      ? const Color(0xFF4a9fd8)
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
