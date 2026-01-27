import 'package:flutter/material.dart';

class GroupDetailsHeader extends StatelessWidget {
  const GroupDetailsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon:  Icon(Icons.arrow_back, color: colors.onSurface),
          ),
          const SizedBox(width: 8),
           Expanded(
            child: Text(
              "Family Netflix",
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon:  Icon(Icons.more_vert, color: colors.onSurface),
          ),
        ],
      ),
    );
  }
}
