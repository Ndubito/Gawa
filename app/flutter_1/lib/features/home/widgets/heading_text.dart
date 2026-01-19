import 'package:flutter/material.dart';

class HeadingText extends StatelessWidget{
  final String text;
  
  const HeadingText({
    super.key,
    required this.text,
  });

  @override
  Widget build (BuildContext context)
 {
    final colors = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        color: colors.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
