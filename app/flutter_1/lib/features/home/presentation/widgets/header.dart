import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String text;

  const Header({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon:  Icon(Icons.arrow_back, color: colors.onSurface),
        ),
        const SizedBox(width: 8),
         Expanded(
          child: Text(
            text,
            style: TextStyle( 
              color: colors.onSurface,
              fontSize: 24,
            ),  
          ),
        ),
      ],
    );
  }
}