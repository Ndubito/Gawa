import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget{

  final VoidCallback onPressed;
  final String text;

  const ActionButton({
    super.key,
    required  this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context)
  {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(
            0xFF2d3561,
          ),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              20,
            ),
          ),
        ),
        child:Text (text),
      ),
    );
  }
}
