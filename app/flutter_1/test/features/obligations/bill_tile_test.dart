import 'package:flutter/material.dart';
import 'package:flutter_1/core/enums.dart';
import 'package:flutter_1/features/obligations/domain/entities/obligation_model.dart';
import 'package:flutter_1/features/obligations/presentation/widgets/bill_tile.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime(2026, 11, 5, 12);

Future<void> _pump(
  WidgetTester tester, {
  required BillDirection direction,
  required ObligationStatus status,
}) {
  final bill = ObligationModel(
    id: 1,
    direction: direction,
    counterpartyId: 9,
    counterpartyName: 'Wanjiku',
    sourceType: ObligationSourceType.expense,
    sourceName: 'Dinner',
    groupName: 'Diani trip',
    amountDueCents: 100000,
    amountPaidCents: status == ObligationStatus.paid ? 100000 : 0,
    currency: Currency.kes,
    status: status,
    dueAt: _now.add(const Duration(days: 2)),
    overdueAt: _now.add(const Duration(days: 3)),
    updatedAt: _now,
  );
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: BillTile(bill: bill, now: _now),
      ),
    ),
  );
}

void main() {
  testWidgets('phrases an open bill I owe', (tester) async {
    await _pump(
      tester,
      direction: BillDirection.owe,
      status: ObligationStatus.pending,
    );
    expect(find.text('You owe Wanjiku'), findsOneWidget);
    expect(find.text('Dinner • Diani trip'), findsOneWidget);
    expect(find.text('KES 1,000'), findsOneWidget);
  });

  testWidgets('phrases a paid bill in the past tense', (tester) async {
    await _pump(
      tester,
      direction: BillDirection.owed,
      status: ObligationStatus.paid,
    );
    expect(find.text('Wanjiku paid you'), findsOneWidget);
    expect(find.text('Paid'), findsOneWidget);
  });

  testWidgets('marks overdue bills', (tester) async {
    await _pump(
      tester,
      direction: BillDirection.owe,
      status: ObligationStatus.overdue,
    );
    expect(find.text('Overdue'), findsOneWidget);
  });
}
