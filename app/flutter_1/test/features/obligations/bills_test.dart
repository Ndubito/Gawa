import 'package:flutter_1/core/enums.dart';
import 'package:flutter_1/features/obligations/domain/bill_buckets.dart';
import 'package:flutter_1/features/obligations/domain/entities/obligation_model.dart';
import 'package:flutter_1/features/obligations/domain/repos/obligations_repo.dart';
import 'package:flutter_1/features/obligations/presentation/cubits/obligations_cubit.dart';
import 'package:flutter_1/features/obligations/presentation/cubits/obligations_state.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime(2026, 11, 5, 12);

ObligationModel _bill({
  int id = 1,
  BillDirection direction = BillDirection.owe,
  ObligationStatus status = ObligationStatus.pending,
  DateTime? dueAt,
  int amountDue = 100000,
  int amountPaid = 0,
  DateTime? updatedAt,
}) => ObligationModel(
  id: id,
  direction: direction,
  counterpartyId: 9,
  counterpartyName: 'Mary',
  sourceType: ObligationSourceType.expense,
  sourceName: 'Dinner',
  amountDueCents: amountDue,
  amountPaidCents: amountPaid,
  currency: Currency.kes,
  status: status,
  dueAt: dueAt ?? _now.add(const Duration(days: 3)),
  overdueAt: (dueAt ?? _now.add(const Duration(days: 3))).add(
    const Duration(days: 1),
  ),
  updatedAt: updatedAt ?? _now,
);

class FakeObligationsRepo extends ObligationsRepo {
  List<ObligationModel> bills = [];
  bool failing = false;

  @override
  Future<List<ObligationModel>> getMyBills() async {
    if (failing) throw Exception('backend unreachable');
    return bills;
  }
}

void main() {
  group('ObligationModel.fromJson', () {
    test('reads a subscription bill phrased from my side', () {
      final bill = ObligationModel.fromJson({
        'id': 4,
        'direction': 'OWE',
        'counterparty': {'userId': 1, 'name': 'Nathan'},
        'source': {
          'type': 'SUBSCRIPTION_CYCLE',
          'name': 'Netflix',
          'groupId': 10,
          'groupName': 'Family',
          'periodStart': '2026-10-31T21:00:00.000Z',
          'periodEnd': '2026-11-30T21:00:00.000Z',
        },
        'amountDue': 50000,
        'amountPaid': 10000,
        'currency': 'KES',
        'status': 'PARTIAL',
        'dueAt': '2026-11-01T06:00:00.000Z',
        'overdueAt': '2026-11-03T06:00:00.000Z',
        'updatedAt': '2026-11-02T06:00:00.000Z',
      });

      expect(bill.direction, BillDirection.owe);
      expect(bill.counterpartyName, 'Nathan');
      expect(bill.sourceType, ObligationSourceType.subscriptionCycle);
      expect(bill.periodStart, isNotNull);
      expect(bill.outstandingCents, 40000);
      expect(bill.isOpen, isTrue);
    });
  });

  group('bucketOf', () {
    test('trusts the backend for overdue', () {
      expect(
        bucketOf(_bill(status: ObligationStatus.overdue), _now),
        BillBucket.overdue,
      );
    });

    test('is due now on the due day and during the grace period', () {
      expect(bucketOf(_bill(dueAt: _now), _now), BillBucket.dueNow);
      expect(
        bucketOf(_bill(dueAt: _now.subtract(const Duration(days: 1))), _now),
        BillBucket.dueNow,
      );
    });

    test('splits the rest into this week and upcoming', () {
      expect(
        bucketOf(_bill(dueAt: _now.add(const Duration(days: 7))), _now),
        BillBucket.thisWeek,
      );
      expect(
        bucketOf(_bill(dueAt: _now.add(const Duration(days: 8))), _now),
        BillBucket.upcoming,
      );
    });

    test('puts paid and cancelled bills under settled', () {
      expect(
        bucketOf(_bill(status: ObligationStatus.paid), _now),
        BillBucket.settled,
      );
      expect(
        bucketOf(_bill(status: ObligationStatus.cancelled), _now),
        BillBucket.settled,
      );
    });
  });

  test('groupByUrgency orders sections by urgency and bills by due date', () {
    final grouped = groupByUrgency([
      _bill(id: 1, dueAt: _now.add(const Duration(days: 20))),
      _bill(id: 2, status: ObligationStatus.overdue),
      _bill(id: 3, dueAt: _now.add(const Duration(days: 5))),
      _bill(id: 4, dueAt: _now.add(const Duration(days: 2))),
    ], _now);

    expect(grouped.keys, [
      BillBucket.overdue,
      BillBucket.thisWeek,
      BillBucket.upcoming,
    ]);
    expect(grouped[BillBucket.thisWeek]!.map((b) => b.id), [4, 3]);
  });

  test('BillTotals counts only what is still outstanding', () {
    final totals = BillTotals.of([
      _bill(amountDue: 100000, amountPaid: 40000),
      _bill(status: ObligationStatus.overdue, amountDue: 50000),
      _bill(status: ObligationStatus.paid, amountDue: 999999),
      _bill(direction: BillDirection.owed, amountDue: 200000),
    ]);

    expect(totals.oweCents, 110000);
    expect(totals.owedCents, 200000);
    expect(totals.overdueOweCount, 1);
  });

  group('ObligationsCubit', () {
    test('loads bills', () async {
      final repo = FakeObligationsRepo()..bills = [_bill()];
      final cubit = ObligationsCubit(obligationsRepo: repo);

      await cubit.loadBills();

      expect((cubit.state as ObligationsLoaded).bills, hasLength(1));
    });

    test('keeps the list on screen while refreshing', () async {
      final repo = FakeObligationsRepo()..bills = [_bill()];
      final cubit = ObligationsCubit(obligationsRepo: repo);
      await cubit.loadBills();

      final emitted = <ObligationsState>[];
      final sub = cubit.stream.listen(emitted.add);
      await cubit.loadBills();
      await Future<void>.delayed(Duration.zero);

      expect(emitted.whereType<ObligationsLoading>(), isEmpty);
      await sub.cancel();
    });

    test('emits Error when the backend fails', () async {
      final repo = FakeObligationsRepo()..failing = true;
      final cubit = ObligationsCubit(obligationsRepo: repo);

      await cubit.loadBills();

      expect(cubit.state, isA<ObligationsError>());
    });
  });
}
