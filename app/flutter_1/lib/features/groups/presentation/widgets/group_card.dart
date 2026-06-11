import 'package:flutter/material.dart';

class GroupCard extends StatelessWidget {
  final String groupName;
  final String? description;

  // Subscription summary — null until the group has a subscription attached
  final String? totalAmount;
  final String? nextCharge;
  final int paidCount;
  final int pendingCount;
  final int failedCount;
  final List<String> memberAvatars;
  final VoidCallback onTap;

  const GroupCard({
    super.key,
    required this.groupName,
    this.description,
    this.totalAmount,
    this.nextCharge,
    this.paidCount = 0,
    this.pendingCount = 0,
    this.failedCount = 0,
    this.memberAvatars = const [],
    required this.onTap,
  });

  bool get _hasSubscription => totalAmount != null;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.tertiary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    groupName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.inversePrimary,
                    ),
                  ),
                ),
                if (totalAmount != null)
                  Text(
                    totalAmount!,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
              ],
            ),
            if (description != null && description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  nextCharge != null
                      ? 'Next charge: $nextCharge'
                      : 'No upcoming charges',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Avatar Stack
                SizedBox(
                  width: 100,
                  height: 32,
                  child: memberAvatars.isEmpty
                      ? const SizedBox.shrink()
                      : Stack(
                          children: [
                            for (int i = 0; i < memberAvatars.take(4).length; i++)
                              Positioned(
                                left: i * 20.0,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: colors.inversePrimary
                                      .withValues(alpha: 0.8 - (i * 0.1)),
                                  child: Text(
                                    memberAvatars[i],
                                    style: TextStyle(
                                      color: colors.onPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
                // Payment Status
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusBackground(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _statusForeground(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusBackground() {
    if (!_hasSubscription) return const Color(0xFFe3edff);
    if (failedCount > 0) return const Color(0xFFffe0e0);
    if (pendingCount > 0) return const Color(0xFFfff4e0);
    return const Color(0xFFe0f7e9);
  }

  Color _statusForeground() {
    if (!_hasSubscription) return const Color(0xFF2456c9);
    if (failedCount > 0) return const Color(0xFFd32f2f);
    if (pendingCount > 0) return const Color(0xFFf57c00);
    return const Color(0xFF2e7d32);
  }

  String _getStatusText() {
    if (!_hasSubscription) {
      return 'No subscription yet';
    } else if (failedCount > 0) {
      return '$paidCount paid • $failedCount failed';
    } else if (pendingCount > 0) {
      return '$paidCount paid • $pendingCount pending';
    } else {
      return 'All paid ✓';
    }
  }
}
