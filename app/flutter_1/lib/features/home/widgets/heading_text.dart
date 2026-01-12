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
    return Text(
      text,
      style: TextStyle(
        color: Color(0xFF2d3561),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
