import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_1/features/groups/domain/entities/group_model.dart';
import 'package:flutter_1/features/groups/presentation/cubits/group_members_cubit.dart';
import 'package:flutter_1/features/groups/presentation/cubits/groups_cubit.dart';
import 'package:flutter_1/features/groups/presentation/cubits/groups_state.dart';
import 'package:flutter_1/features/groups/presentation/cubits/invites_cubit.dart';
import 'package:flutter_1/features/groups/presentation/widgets/invitations_section.dart';
import 'package:flutter_1/features/subscriptions/presentation/cubits/group_subscriptions_cubit.dart';
import 'package:flutter_1/features/subscriptions/presentation/cubits/subscriptions_cubit.dart';
import 'package:flutter_1/features/subscriptions/presentation/cubits/subscriptions_state.dart';
import 'package:flutter_1/features/obligations/presentation/cubits/obligations_cubit.dart';
import 'package:flutter_1/features/expenses/domain/repos/expenses_repo.dart';
import 'package:flutter_1/features/expenses/presentation/cubits/group_expenses_cubit.dart';
import '../widgets/group_card.dart';
import '../../../home/presentation/widgets/heading_text.dart';
import './group_details_page.dart';
import './create_group_page.dart';
import '../widgets/long_action_button.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  @override
  void initState() {
    super.initState();
    // Load once when the page first appears
    final cubit = context.read<GroupsCubit>();
    if (cubit.state is GroupsInitial) {
      cubit.loadGroups();
    }
    // Feeds the per-group subscription counts on the cards
    context.read<SubscriptionsCubit>().loadMine();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return BlocProvider(
      create: (_) =>
          InvitesCubit(groupsRepo: context.read<GroupsCubit>().groupsRepo)
            ..loadInvites(),
      child: Scaffold(
        backgroundColor: colors.surface,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Builder(
              builder: (innerContext) => RefreshIndicator(
                onRefresh: () => Future.wait([
                  context.read<GroupsCubit>().loadGroups(),
                  context.read<SubscriptionsCubit>().loadMine(),
                  innerContext.read<InvitesCubit>().loadInvites(),
                ]),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HeadingText(text: 'Groups'),
                        const SizedBox(height: 12),

                        LongActionButton(
                          buttonLabel: const Text("Create New Group"),
                          icon: const Icon(Icons.add),
                          onClick: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CreateGroupPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),

                        InvitationsSection(
                          onAccepted: () =>
                              context.read<GroupsCubit>().loadGroups(),
                        ),

                        BlocBuilder<GroupsCubit, GroupsState>(
                          builder: (context, state) {
                            if (state is GroupsLoading ||
                                state is GroupsInitial) {
                              return _buildLoading(colors);
                            }
                            if (state is GroupsError) {
                              return _buildError(
                                context,
                                colors,
                                state.message,
                              );
                            }
                            final groups = (state as GroupsLoaded).groups;
                            if (groups.isEmpty) {
                              return _buildEmpty(colors);
                            }
                            return _buildList(groups);
                          },
                        ),

                        const SizedBox(
                          height: 100,
                        ), // Space for floating nav bar
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: CircularProgressIndicator(color: colors.inversePrimary),
      ),
    );
  }

  Widget _buildError(BuildContext context, ColorScheme colors, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.cloud_off_outlined, size: 48, color: colors.primary),
            const SizedBox(height: 12),
            Text(
              "Couldn't load your groups",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.read<GroupsCubit>().loadGroups(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colors.inversePrimary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.groups_outlined,
                size: 44,
                color: colors.inversePrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No groups yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Create a group to start splitting\nshared payments with others.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<GroupModel> groups) {
    return BlocBuilder<SubscriptionsCubit, SubscriptionsState>(
      builder: (context, subsState) {
        // Null until loaded, so cards don't flash "No subscription yet"
        Map<int, int>? subscriptionCounts;
        if (subsState is SubscriptionsLoaded) {
          subscriptionCounts = {};
          for (final sub in subsState.subscriptions) {
            subscriptionCounts.update(
              sub.groupId,
              (n) => n + 1,
              ifAbsent: () => 1,
            );
          }
        }
        return _buildCards(groups, subscriptionCounts);
      },
    );
  }

  Widget _buildCards(
    List<GroupModel> groups,
    Map<int, int>? subscriptionCounts,
  ) {
    return Column(
      children: [
        for (int i = 0; i < groups.length; i++) ...[
          _AnimatedEntry(
            index: i,
            child: GroupCard(
              groupName: groups[i].name,
              description: groups[i].description,
              subscriptionCount: subscriptionCounts == null
                  ? null
                  : subscriptionCounts[groups[i].id] ?? 0,
              onTap: () {
                final groupsRepo = context.read<GroupsCubit>().groupsRepo;
                final subsRepo = context
                    .read<SubscriptionsCubit>()
                    .subscriptionsRepo;
                final expensesRepo = context.read<ExpensesRepo>();
                final groupId = groups[i].id;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (_) => GroupMembersCubit(
                            groupsRepo: groupsRepo,
                            groupId: groupId,
                          )..loadMembers(),
                        ),
                        BlocProvider(
                          create: (_) => GroupSubscriptionsCubit(
                            subscriptionsRepo: subsRepo,
                            groupId: groupId,
                          )..loadSubscriptions(),
                        ),
                        BlocProvider(
                          create: (_) => GroupExpensesCubit(
                            expensesRepo: expensesRepo,
                            groupId: groupId,
                          )..loadExpenses(),
                        ),
                      ],
                      child: GroupDetailsPage(group: groups[i]),
                    ),
                  ),
                ).then((_) {
                  if (!mounted) return;
                  // Subscriptions or expenses may have changed inside
                  context.read<SubscriptionsCubit>().loadMine();
                  context.read<ObligationsCubit>().loadBills();
                });
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

/// Staggered fade + slide-up entrance for list items.
class _AnimatedEntry extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedEntry({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index.clamp(0, 5) * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
