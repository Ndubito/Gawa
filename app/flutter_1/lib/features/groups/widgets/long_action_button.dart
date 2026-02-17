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

    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onClick,
        icon: icon,
        label: buttonLabel,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.inversePrimary,
          foregroundColor: colors.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

