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
      final colors = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
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
