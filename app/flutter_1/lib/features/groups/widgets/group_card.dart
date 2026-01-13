import 'package:flutter/material.dart';

class GroupCard extends StatelessWidget {
  final String groupName;
  final String totalAmount;
  final String nextCharge;
  final int memberCount;
  final int paidCount;
  final int pendingCount;
  final int failedCount;
  final List<String> memberAvatars;
  final VoidCallback onTap;

  const GroupCard({
    super.key,
    required this.groupName,
    required this.totalAmount,
    required this.nextCharge,
    required this.memberCount,
    required this.paidCount,
    required this.pendingCount,
    this.failedCount = 0,
    required this.memberAvatars,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1a1a2e),
                    ),
                  ),
                ),
                Text(
                  totalAmount,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6c63ff),
                  ),
                ),
              ],
            ),
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
                  'Next charge: $nextCharge',
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
                                  backgroundColor: Color(0xFF6c63ff).withValues(alpha: 0.8 - (i * 0.1)),
                                  child: Text(
                                    memberAvatars[i],
                                    style: const TextStyle(
                                      color: Colors.white,
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: failedCount > 0
                        ? const Color(0xFFffe0e0)
                        : pendingCount > 0
                            ? const Color(0xFFfff4e0)
                            : const Color(0xFFe0f7e9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: failedCount > 0
                          ? const Color(0xFFd32f2f)
                          : pendingCount > 0
                              ? const Color(0xFFf57c00)
                              : const Color(0xFF2e7d32),
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
  
  String _getStatusText() {
    if (failedCount > 0) {
      return '$paidCount paid • $failedCount failed';
    } else if (pendingCount > 0) {
      return '$paidCount paid • $pendingCount pending';
    } else {
      return 'All paid ✓';
    }
  }

  }