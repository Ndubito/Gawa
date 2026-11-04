import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_1/features/home/presentation/widgets/heading_text.dart';
import 'package:flutter_1/features/obligations/domain/bill_buckets.dart';
import 'package:flutter_1/features/obligations/domain/entities/obligation_model.dart';
import 'package:flutter_1/features/obligations/presentation/cubits/obligations_cubit.dart';
import 'package:flutter_1/features/obligations/presentation/cubits/obligations_state.dart';
import 'package:flutter_1/features/obligations/presentation/widgets/bill_tile.dart';
import 'package:flutter_1/features/obligations/presentation/widgets/bills_summary_card.dart';

/// Home's money snapshot: totals, then whatever needs attention first.
class HomeBillsSection extends StatelessWidget {
  const HomeBillsSection({super.key});

  static const _maxUrgent = 3;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ObligationsCubit, ObligationsState>(
      builder: (context, state) {
        if (state is ObligationsError) {
          return Row(
            children: [
              const Expanded(
                child: Text(
                  "Couldn't load your bills",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => context.read<ObligationsCubit>().loadBills(),
                child: const Text('Retry'),
              ),
            ],
          );
        }
        if (state is! ObligationsLoaded) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final now = DateTime.now();
        final open = state.bills.where((b) => b.isOpen).toList()
          ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
        final urgent = open
            .where((b) => b.direction == BillDirection.owe)
            .where((b) {
              final bucket = bucketOf(b, now);
              return bucket == BillBucket.overdue ||
                  bucket == BillBucket.dueNow;
            })
            .take(_maxUrgent)
            .toList();
        final nextUp = open.where((b) => !urgent.contains(b)).firstOrNull;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BillsSummaryCard(totals: BillTotals.of(state.bills)),
            const SizedBox(height: 20),
            if (urgent.isNotEmpty) ...[
              const HeadingText(text: 'Needs attention'),
              const SizedBox(height: 12),
              for (final bill in urgent) _tile(bill, now),
              const SizedBox(height: 12),
            ],
            if (nextUp != null) ...[
              const HeadingText(text: 'Next up'),
              const SizedBox(height: 12),
              _tile(nextUp, now),
            ],
            if (open.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "You're all settled — nothing owed either way.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _tile(ObligationModel bill, DateTime now) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: BillTile(bill: bill, now: now),
  );
}
