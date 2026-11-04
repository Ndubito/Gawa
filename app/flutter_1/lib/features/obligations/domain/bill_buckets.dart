import 'package:flutter_1/core/enums.dart';
import 'package:flutter_1/features/obligations/domain/entities/obligation_model.dart';

/// Urgency groups for the bills list, in display order.
enum BillBucket {
  overdue('Overdue'),
  dueNow('Due now'),
  thisWeek('This week'),
  upcoming('Upcoming'),
  settled('Settled');

  final String label;
  const BillBucket(this.label);
}

DateTime _day(DateTime t) {
  final local = t.toLocal();
  return DateTime(local.year, local.month, local.day);
}

/// Due today or already past due but still inside the grace period counts as
/// "due now"; the backend flips bills to OVERDUE once grace runs out.
BillBucket bucketOf(ObligationModel bill, DateTime now) {
  if (!bill.isOpen) return BillBucket.settled;
  if (bill.status == ObligationStatus.overdue) return BillBucket.overdue;

  final daysUntilDue = _day(bill.dueAt).difference(_day(now)).inDays;
  if (daysUntilDue <= 0) return BillBucket.dueNow;
  if (daysUntilDue <= 7) return BillBucket.thisWeek;
  return BillBucket.upcoming;
}

/// Bills grouped by urgency (empty groups left out). Open bills are soonest
/// first; settled ones most recently settled first.
Map<BillBucket, List<ObligationModel>> groupByUrgency(
  Iterable<ObligationModel> bills,
  DateTime now,
) {
  final grouped = <BillBucket, List<ObligationModel>>{};
  for (final bill in bills) {
    grouped.putIfAbsent(bucketOf(bill, now), () => []).add(bill);
  }
  for (final entry in grouped.entries) {
    entry.value.sort(
      (a, b) => entry.key == BillBucket.settled
          ? b.updatedAt.compareTo(a.updatedAt)
          : a.dueAt.compareTo(b.dueAt),
    );
  }
  return {
    for (final bucket in BillBucket.values)
      if (grouped[bucket] != null) bucket: grouped[bucket]!,
  };
}

/// Outstanding totals across open bills, in cents.
class BillTotals {
  final int oweCents;
  final int owedCents;
  final int overdueOweCount;

  const BillTotals({
    required this.oweCents,
    required this.owedCents,
    required this.overdueOweCount,
  });

  factory BillTotals.of(Iterable<ObligationModel> bills) {
    var owe = 0, owed = 0, overdue = 0;
    for (final bill in bills.where((b) => b.isOpen)) {
      if (bill.direction == BillDirection.owe) {
        owe += bill.outstandingCents;
        if (bill.status == ObligationStatus.overdue) overdue++;
      } else {
        owed += bill.outstandingCents;
      }
    }
    return BillTotals(oweCents: owe, owedCents: owed, overdueOweCount: overdue);
  }
}
