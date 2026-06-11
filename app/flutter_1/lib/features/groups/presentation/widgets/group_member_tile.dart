import 'package:flutter/material.dart';
import 'package:flutter_1/features/groups/domain/entities/group_member_model.dart';

class GroupMemberTile extends StatelessWidget {
  final GroupMemberModel member;

  /// Shown only to the group owner, and never on the owner's own row.
  final VoidCallback? onRemove;

  const GroupMemberTile({super.key, required this.member, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final name = member.displayName;

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: member.isOwner
              ? colors.inversePrimary
              : colors.primary.withValues(alpha: 0.2),
          child: Text(
            name[0].toUpperCase(),
            style: TextStyle(
              color: member.isOwner ? colors.onPrimary : colors.primary,
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
                  Flexible(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  if (member.isOwner) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.inversePrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Owner',
                        style: TextStyle(
                          fontSize: 10,
                          color: colors.inversePrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (member.phoneNumber != null &&
                  member.phoneNumber!.isNotEmpty &&
                  member.phoneNumber != name)
                Text(
                  member.phoneNumber!,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
            ],
          ),
        ),
        if (onRemove != null)
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.person_remove_outlined,
                size: 20, color: Colors.grey),
            tooltip: 'Remove member',
          ),
      ],
    );
  }
}
