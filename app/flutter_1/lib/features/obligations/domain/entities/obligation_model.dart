import 'package:flutter_1/core/enums.dart';

/// Whether the signed-in user owes this bill or is owed it.
enum BillDirection { owe, owed }

/// A bill as the signed-in user sees it: who the other person is, what it's
/// for, and how much is outstanding. Amounts are in cents.
class ObligationModel {
  final int id;
  final BillDirection direction;
  final int counterpartyId;
  final String counterpartyName;
  final ObligationSourceType sourceType;

  /// Subscription or expense name, e.g. "Netflix" or "Dinner".
  final String sourceName;
  final String? groupName;

  /// Start of the billing period, for subscription bills.
  final DateTime? periodStart;
  final int amountDueCents;
  final int amountPaidCents;
  final Currency currency;
  final ObligationStatus status;
  final DateTime dueAt;
  final DateTime overdueAt;
  final DateTime updatedAt;

  const ObligationModel({
    required this.id,
    required this.direction,
    required this.counterpartyId,
    required this.counterpartyName,
    required this.sourceType,
    required this.sourceName,
    this.groupName,
    this.periodStart,
    required this.amountDueCents,
    required this.amountPaidCents,
    required this.currency,
    required this.status,
    required this.dueAt,
    required this.overdueAt,
    required this.updatedAt,
  });

  bool get isOpen =>
      status == ObligationStatus.pending ||
      status == ObligationStatus.partial ||
      status == ObligationStatus.overdue;

  int get outstandingCents => amountDueCents - amountPaidCents;

  factory ObligationModel.fromJson(Map<String, dynamic> json) {
    final counterparty = json['counterparty'] as Map<String, dynamic>;
    final source = json['source'] as Map<String, dynamic>;
    final periodStart = source['periodStart'] as String?;
    return ObligationModel(
      id: json['id'] as int,
      direction: json['direction'] == 'OWE'
          ? BillDirection.owe
          : BillDirection.owed,
      counterpartyId: counterparty['userId'] as int,
      counterpartyName: counterparty['name'] as String,
      sourceType: ObligationSourceType.fromString(source['type'] as String),
      sourceName: source['name'] as String,
      groupName: source['groupName'] as String?,
      periodStart: periodStart == null ? null : DateTime.parse(periodStart),
      amountDueCents: json['amountDue'] as int,
      amountPaidCents: json['amountPaid'] as int,
      currency: Currency.fromString(json['currency'] as String),
      status: ObligationStatus.fromString(json['status'] as String),
      dueAt: DateTime.parse(json['dueAt'] as String),
      overdueAt: DateTime.parse(json['overdueAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
