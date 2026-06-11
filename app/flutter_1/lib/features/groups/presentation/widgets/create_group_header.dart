import 'package:flutter/material.dart';

class CreateGroupHeader extends StatelessWidget {
  const CreateGroupHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      // color: Colors.white,
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
              "Create a Group",
              style: TextStyle( 
                color: colors.onSurface,
                fontSize: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}