// Rule Item Widget
import 'package:flutter/material.dart';

class RuleItem extends StatelessWidget {
  final String label;
  final String value;

  const RuleItem({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1a1a2e),
          ),
        ),
      ],
    );
  }
}