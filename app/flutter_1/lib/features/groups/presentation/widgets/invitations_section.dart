import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_1/features/groups/domain/entities/group_invite_model.dart';
import 'package:flutter_1/features/groups/presentation/cubits/invites_cubit.dart';
import 'package:flutter_1/features/groups/presentation/cubits/invites_state.dart';

/// Pending group invitations for the signed-in user. Renders nothing when
/// there are none, so it can sit at the top of the groups list.
class InvitationsSection extends StatelessWidget {
  /// Called after an invite is accepted, so the caller can refresh its groups.
  final VoidCallback onAccepted;

  const InvitationsSection({super.key, required this.onAccepted});

  Future<void> _respond(
    BuildContext context,
    GroupInviteModel invite, {
    required bool accept,
  }) async {
    final cubit = context.read<InvitesCubit>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (accept) {
        await cubit.accept(invite.groupId);
        onAccepted();
        messenger.showSnackBar(
          SnackBar(content: Text('You joined "${invite.groupName}"')),
        );
      } else {
        await cubit.decline(invite.groupId);
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<InvitesCubit, InvitesState>(
      builder: (context, state) {
        if (state is InvitesError) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Couldn't load your invitations",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () => context.read<InvitesCubit>().loadInvites(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is! InvitesLoaded || state.invites.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invitations (${state.invites.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              for (final invite in state.invites) ...[
                _InviteCard(
                  invite: invite,
                  busy: state.responding.contains(invite.groupId),
                  onAccept: () => _respond(context, invite, accept: true),
                  onDecline: () => _respond(context, invite, accept: false),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _InviteCard extends StatelessWidget {
  final GroupInviteModel invite;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _InviteCard({
    required this.invite,
    required this.busy,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.tertiary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.inversePrimary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mail_outline, size: 20, color: colors.inversePrimary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  invite.groupName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${invite.invitedByName} invited you to join',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          if (invite.groupDescription != null &&
              invite.groupDescription!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              invite.groupDescription!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: colors.onSurface),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: busy ? null : onDecline,
                child: const Text('Decline'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: busy ? null : onAccept,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.inversePrimary,
                  foregroundColor: colors.onPrimary,
                ),
                child: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Accept'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
