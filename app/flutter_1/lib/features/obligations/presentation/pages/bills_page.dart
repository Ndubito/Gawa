import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_1/features/home/presentation/widgets/heading_text.dart';
import 'package:flutter_1/features/obligations/domain/bill_buckets.dart';
import 'package:flutter_1/features/obligations/domain/entities/obligation_model.dart';
import 'package:flutter_1/features/obligations/presentation/cubits/obligations_cubit.dart';
import 'package:flutter_1/features/obligations/presentation/cubits/obligations_state.dart';
import 'package:flutter_1/features/obligations/presentation/widgets/bill_tile.dart';
import 'package:flutter_1/features/obligations/presentation/widgets/bills_summary_card.dart';

/// Every bill the user owes or is owed, grouped by urgency.
class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  BillDirection _direction = BillDirection.owe;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ObligationsCubit>();
    if (cubit.state is ObligationsInitial) cubit.loadBills();
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
            onRefresh: () => context.read<ObligationsCubit>().loadBills(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: BlocBuilder<ObligationsCubit, ObligationsState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const HeadingText(text: 'Bills'),
                      const SizedBox(height: 12),
                      if (state is ObligationsLoaded) ...[
                        BillsSummaryCard(totals: BillTotals.of(state.bills)),
                        const SizedBox(height: 16),
                        _directionToggle(state.bills),
                        const SizedBox(height: 16),
                        ..._billSections(state.bills),
                      ] else if (state is ObligationsError)
                        _error(state.message)
                      else
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 80),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      const SizedBox(height: 100),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _directionToggle(List<ObligationModel> bills) {
    int openCount(BillDirection d) =>
        bills.where((b) => b.direction == d && b.isOpen).length;
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<BillDirection>(
        // Default selected colours are unreadable on the dark theme
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: colors.inversePrimary,
          selectedForegroundColor: colors.onPrimary,
          foregroundColor: colors.onSurface,
        ),
        segments: [
          ButtonSegment(
            value: BillDirection.owe,
            label: Text('I owe (${openCount(BillDirection.owe)})'),
          ),
          ButtonSegment(
            value: BillDirection.owed,
            label: Text('Owed to me (${openCount(BillDirection.owed)})'),
          ),
        ],
        selected: {_direction},
        showSelectedIcon: false,
        onSelectionChanged: (s) => setState(() => _direction = s.first),
      ),
    );
  }

  List<Widget> _billSections(List<ObligationModel> bills) {
    final now = DateTime.now();
    final grouped = groupByUrgency(
      bills.where((b) => b.direction == _direction),
      now,
    );
    final open = grouped.entries.where((e) => e.key != BillBucket.settled);
    final settled = grouped[BillBucket.settled] ?? [];

    if (open.isEmpty && settled.isEmpty) return [_empty()];

    return [
      if (open.isEmpty) _empty(),
      for (final section in open) ...[
        _sectionHeader(section.key.label, section.value.length),
        for (final bill in section.value)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: BillTile(bill: bill, now: now),
          ),
        const SizedBox(height: 8),
      ],
      if (settled.isNotEmpty)
        Theme(
          // Drop the ExpansionTile divider lines
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: _sectionHeader('Settled (last 90 days)', settled.length),
            children: [
              for (final bill in settled)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: BillTile(bill: bill, now: now),
                ),
            ],
          ),
        ),
    ];
  }

  Widget _sectionHeader(String label, int count) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$label · $count',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: colors.onSurface,
        ),
      ),
    );
  }

  Widget _empty() {
    final owe = _direction == BillDirection.owe;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              owe ? Icons.celebration_outlined : Icons.savings_outlined,
              size: 44,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              owe ? "You're all settled" : 'Nobody owes you right now',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              owe
                  ? 'Bills you owe will show up here.'
                  : 'Shares of subscriptions and expenses you paid for show up here.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _error(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            const Text(
              "Couldn't load your bills",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.read<ObligationsCubit>().loadBills(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
