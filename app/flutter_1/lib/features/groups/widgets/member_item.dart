// Member Item Widget
import 'package:flutter/material.dart';

class MemberItem extends StatelessWidget {
  final String name;
  final String amount;
  final String status;
  final bool isOrganizer;

  const MemberItem({
    super.key,
    required this.name,
    required this.amount,
    required this.status,
    this.isOrganizer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFF6c63ff).withOpacity(0.2),
          child: Text(
            name[0],
            style: const TextStyle(
              color: Color(0xFF6c63ff),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1a1a2e),
                    ),
                  ),
                  if (isOrganizer) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6c63ff).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Organizer',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6c63ff),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: status == 'Paid'
                ? const Color(0xFFe0f7e9)
                : status == 'Pending'
                    ? const Color(0xFFfff4e0)
                    : const Color(0xFFffe0e0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: status == 'Paid'
                  ? const Color(0xFF2e7d32)
                  : status == 'Pending'
                      ? const Color(0xFFf57c00)
                      : const Color(0xFFd32f2f),
            ),
          ),
        ),
      ],
    );
  }
}