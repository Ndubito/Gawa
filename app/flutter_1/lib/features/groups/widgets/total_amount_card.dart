import 'package:flutter/material.dart';

class TotalAmountCard extends StatelessWidget {
  const TotalAmountCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
        final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children:  [
          Text(
            'Total Amount',
            style: TextStyle(
              color: colors.primary,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '1,500 ksh',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Next charge: Jan 15',
            style: TextStyle(
              color: colors.primary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

