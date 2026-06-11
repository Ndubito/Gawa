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
    final colors = Theme.of(context).colorScheme;
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
            color: colors.tertiary,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: colors.inversePrimary.withValues(alpha: 0.15),
                blurRadius: 3,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () => onItemSelected(0),
                icon: Icon(
                  weight: 1,

                  Icons.home_outlined,
                  color: selectedIndex == 0 ? colors.inversePrimary : colors.primary,
                ),
              ),
              IconButton(
                onPressed: () => onItemSelected(1),
                icon: Icon(
                  Icons.people_outline,
                  weight: 1,
                  color: selectedIndex == 1 ? colors.inversePrimary : colors.primary,
                ),
              ),
              IconButton(
                onPressed: () => onItemSelected(2),
                icon: Icon(
                  weight: 1,

                  Icons.shopping_bag_outlined,
                  color: selectedIndex == 2 ? colors.inversePrimary : colors.primary,
                ),
              ),
              IconButton(
                onPressed: () => onItemSelected(3),
                icon: Icon(
                  weight: 1,

                  Icons.history, // Activity
                  color: selectedIndex == 3 ? colors.inversePrimary : colors.primary,
                ),
              ),
              IconButton(
                onPressed: () => onItemSelected(4),
                icon: Icon(
                  weight: 1,

                  Icons.person_outline,
                  color: selectedIndex == 4 ? colors.inversePrimary : colors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
