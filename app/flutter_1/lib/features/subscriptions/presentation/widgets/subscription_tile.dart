import 'package:flutter/material.dart';
import 'package:flutter_1/core/enums.dart';
import 'package:flutter_1/features/subscriptions/domain/entities/subscription_model.dart';

/// A single subscription row: name, monthly amount, status, and — when the
/// member count is known — each member's equal share.
class SubscriptionTile extends StatelessWidget {
  final SubscriptionModel subscription;

  /// When provided (> 0), shows the per-member split.
  final int? memberCount;

  /// Shown only to the group owner.
  final VoidCallback? onDelete;

  const SubscriptionTile({
    super.key,
    required this.subscription,
    this.memberCount,
    this.onDelete,
  });

  static String formatKes(double value) {
    // Whole shillings with thousands separators, e.g. 1500.0 -> "1,500".
    final whole = value.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
      buffer.write(whole[i]);
    }
    return buffer.toString();
  }

  Color _statusColor() {
    switch (subscription.status) {
      case SubscriptionStatus.active:
        return Colors.green;
      case SubscriptionStatus.paused:
        return Colors.orange;
      case SubscriptionStatus.cancelled:
        return Colors.red;
    }
  }

  String _statusLabel() {
    switch (subscription.status) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.paused:
        return 'Paused';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _scheduleLabel() {
    switch (subscription.schedule) {
      case SubscriptionSchedule.daily:
        return 'Daily';
      case SubscriptionSchedule.weekly:
        return 'Weekly';
      case SubscriptionSchedule.monthly:
        return 'Monthly';
      case SubscriptionSchedule.yearly:
        return 'Yearly';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusColor = _statusColor();
    final showShare = memberCount != null && memberCount! > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.tertiary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  subscription.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                  tooltip: 'Delete subscription',
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'KES ${formatKes(subscription.amountValue)} • ${_scheduleLabel()}',
            style: TextStyle(fontSize: 14, color: colors.primary),
          ),
          if (showShare) ...[
            const SizedBox(height: 4),
            Text(
              'KES ${formatKes(subscription.sharePerMember(memberCount!))} each '
              '($memberCount ${memberCount == 1 ? 'member' : 'members'})',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}
