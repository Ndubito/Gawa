import 'package:flutter/material.dart';

class LongActionButton extends StatelessWidget {

  final Text buttonLabel;
  final VoidCallback onClick;
  final Icon icon;

  const LongActionButton({
    super.key,
    required this.buttonLabel,
    required this.onClick,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onClick,
        icon: icon,
        label: buttonLabel,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6c63ff),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

