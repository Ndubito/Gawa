import 'package:flutter/material.dart';
import 'package:flutter_1/core/enums.dart';
import 'package:flutter_1/core/money.dart';
import 'package:flutter_1/features/obligations/domain/bill_buckets.dart';
import 'package:flutter_1/features/obligations/domain/entities/obligation_model.dart';

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _shortDate(DateTime t) {
  final d = t.toLocal();
  return '${_weekdays[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}';
}

/// One bill: who, what for, how much is left, and how urgent it is.
class BillTile extends StatelessWidget {
  final ObligationModel bill;
  final DateTime now;

  const BillTile({super.key, required this.bill, required this.now});

  String get _headline {
    final name = bill.counterpartyName;
    final owe = bill.direction == BillDirection.owe;
    if (bill.isOpen) return owe ? 'You owe $name' : '$name owes you';
    if (bill.status == ObligationStatus.paid) {
      return owe ? 'You paid $name' : '$name paid you';
    }
    return owe ? 'You owed $name' : '$name owed you';
  }

  String get _detail {
    final parts = <String>[bill.sourceName];
    if (bill.periodStart != null) {
      parts.add(_months[bill.periodStart!.toLocal().month - 1]);
    }
    if (bill.groupName != null) parts.add(bill.groupName!);
    return parts.join(' • ');
  }

  (String, Color) _status(ColorScheme colors) {
    switch (bucketOf(bill, now)) {
      case BillBucket.overdue:
        return ('Overdue', Colors.red);
      case BillBucket.dueNow:
        return ('Due now', Colors.orange);
      case BillBucket.thisWeek:
      case BillBucket.upcoming:
        return ('Due ${_shortDate(bill.dueAt)}', colors.primary);
      case BillBucket.settled:
        return bill.status == ObligationStatus.paid
            ? ('Paid', Colors.green)
            : ('Cancelled', Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (statusLabel, statusColor) = _status(colors);
    final amount = bill.isOpen ? bill.outstandingCents : bill.amountDueCents;
    final name = bill.counterpartyName;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.tertiary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colors.inversePrimary.withValues(alpha: 0.15),
            child: Text(
              name.isEmpty ? '?' : name.characters.first.toUpperCase(),
              style: TextStyle(
                color: colors.inversePrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _headline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'KES ${formatKesCents(amount)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: bill.direction == BillDirection.owed && bill.isOpen
                      ? Colors.green
                      : colors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
