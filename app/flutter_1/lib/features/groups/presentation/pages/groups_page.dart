import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_1/features/groups/domain/entities/group_model.dart';
import 'package:flutter_1/features/groups/presentation/cubits/groups_cubit.dart';
import 'package:flutter_1/features/groups/presentation/cubits/groups_state.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: RefreshIndicator(
            onRefresh: () => context.read<GroupsCubit>().loadGroups(),
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

                    BlocBuilder<GroupsCubit, GroupsState>(
                      builder: (context, state) {
                        if (state is GroupsLoading || state is GroupsInitial) {
                          return _buildLoading(colors);
                        }
                        if (state is GroupsError) {
                          return _buildError(context, colors, state.message);
                        }
                        final groups = (state as GroupsLoaded).groups;
                        if (groups.isEmpty) {
                          return _buildEmpty(colors);
                        }
                        return _buildList(groups);
                      },
                    ),

                    const SizedBox(height: 100), // Space for floating nav bar
                  ],
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
    return Column(
      children: [
        for (int i = 0; i < groups.length; i++) ...[
          _AnimatedEntry(
            index: i,
            child: GroupCard(
              groupName: groups[i].name,
              description: groups[i].description,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupDetailsPage(group: groups[i]),
                  ),
                );
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
