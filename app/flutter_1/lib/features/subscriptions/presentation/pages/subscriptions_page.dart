import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_1/core/enums.dart';
import 'package:flutter_1/features/subscriptions/domain/entities/subscription_model.dart';
import 'package:flutter_1/features/subscriptions/presentation/cubits/subscriptions_cubit.dart';
import 'package:flutter_1/features/subscriptions/presentation/cubits/subscriptions_state.dart';
import 'package:flutter_1/features/subscriptions/presentation/widgets/subscription_tile.dart';
import '../../../home/presentation/widgets/heading_text.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Active', 'Paused', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    final cubit = context.read<SubscriptionsCubit>();
    if (cubit.state is SubscriptionsInitial) {
      cubit.loadMine();
    }
  }

  bool _matchesFilter(SubscriptionModel sub) {
    switch (_selectedFilter) {
      case 'Active':
        return sub.status == SubscriptionStatus.active;
      case 'Paused':
        return sub.status == SubscriptionStatus.paused;
      case 'Cancelled':
        return sub.status == SubscriptionStatus.cancelled;
      default:
        return true;
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
            onRefresh: () => context.read<SubscriptionsCubit>().loadMine(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.all(20),
                constraints: const BoxConstraints(minHeight: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeadingText(text: 'Subscriptions'),
                    const SizedBox(height: 4),
                    const Text(
                      'Every shared bill across your groups. Create and manage '
                      'them inside a group.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // Filters
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filters.map((filter) {
                          final isSelected = _selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(filter),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _selectedFilter = filter);
                                }
                              },
                              selectedColor: colors.inversePrimary,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? colors.onPrimary
                                    : colors.inversePrimary,
                              ),
                              backgroundColor: colors.tertiary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide.none,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    BlocBuilder<SubscriptionsCubit, SubscriptionsState>(
                      builder: (context, state) {
                        if (state is SubscriptionsLoading ||
                            state is SubscriptionsInitial) {
                          return _loading(colors);
                        }
                        if (state is SubscriptionsError) {
                          return _error(context, colors, state.message);
                        }
                        final all = (state as SubscriptionsLoaded).subscriptions;
                        final subs = all.where(_matchesFilter).toList();
                        if (subs.isEmpty) {
                          return _empty(colors, all.isEmpty);
                        }
                        return Column(
                          children: [
                            for (final sub in subs) ...[
                              SubscriptionTile(subscription: sub),
                              const SizedBox(height: 12),
                            ],
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loading(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: CircularProgressIndicator(color: colors.inversePrimary),
      ),
    );
  }

  Widget _error(BuildContext context, ColorScheme colors, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.cloud_off_outlined, size: 48, color: colors.primary),
            const SizedBox(height: 12),
            Text(
              "Couldn't load subscriptions",
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
              onPressed: () => context.read<SubscriptionsCubit>().loadMine(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(ColorScheme colors, bool noneAtAll) {
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
                Icons.subscriptions_outlined,
                size: 44,
                color: colors.inversePrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              noneAtAll ? 'No subscriptions yet' : 'Nothing here',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              noneAtAll
                  ? 'Open a group and add a subscription to\nstart splitting a shared bill.'
                  : 'No subscriptions match this filter.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
