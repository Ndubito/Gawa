import 'package:flutter/material.dart';
import 'package:flutter_1/core/money.dart';
import 'package:flutter_1/features/obligations/domain/bill_buckets.dart';

/// "You owe / You're owed" totals across every open bill.
class BillsSummaryCard extends StatelessWidget {
  final BillTotals totals;

  const BillsSummaryCard({super.key, required this.totals});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    Widget half(String label, int cents, Color color, {String? note}) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'KES ${formatKesCents(cents)}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (note != null) ...[
              const SizedBox(height: 2),
              Text(
                note,
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.tertiary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          half(
            'You owe',
            totals.oweCents,
            colors.onSurface,
            note: totals.overdueOweCount > 0
                ? '${totals.overdueOweCount} overdue'
                : null,
          ),
          Container(
            width: 1,
            height: 44,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 20),
          half("You're owed", totals.owedCents, Colors.green),
        ],
      ),
    );
  }
}
