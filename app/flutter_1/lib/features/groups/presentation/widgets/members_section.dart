import 'package:flutter/material.dart';
import './member_item.dart';

class MembersSection extends StatelessWidget {
  const MembersSection({
    super.key,
    required this.membersExpanded,
    required this.onToggle,
  });

  final bool membersExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(
                  'Members (4)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                Icon(
                  membersExpanded ? Icons.expand_less : Icons.expand_more,
                  color: colors.onSurface,
                ),
              ],
            ),
            if (membersExpanded) ...[
              const SizedBox(height: 16),
              MemberItem(
                name: 'Nathan (You)',
                amount: '375 ksh',
                status: 'Paid',
                isOrganizer: true,
              ),
              const SizedBox(height: 12),
              MemberItem(name: 'Mom', amount: '375 ksh', status: 'Paid'),
              const SizedBox(height: 12),
              MemberItem(name: 'Dad', amount: '375 ksh', status: 'Paid'),
              const SizedBox(height: 12),
              MemberItem(name: 'Sister', amount: '375 ksh', status: 'Pending'),
            ],
          ],
        ),
      ),
    );
  }
}
