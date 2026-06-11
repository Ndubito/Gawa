import 'package:flutter_1/core/enums.dart';

class ObligationModel {
  final int id;
  final int? subscriptionCycleId;
  final int? expenseId;
  final int userId;
  final int recipientId;
  final ObligationSourceType sourceType;
  final int amountDue;
  final int amountPaid;
  final Currency currency;
  final ObligationStatus status;
  final DateTime dueAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ObligationModel({
    required this.id,
    this.subscriptionCycleId,
    this.expenseId,
    required this.userId,
    required this.recipientId,
    required this.sourceType,
    required this.amountDue,
    required this.amountPaid,
    required this.currency,
    required this.status,
    required this.dueAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ObligationModel.fromJson(Map<String, dynamic> json) {
    return ObligationModel(
      id: json['id'] as int,
      subscriptionCycleId: json['subscriptionCycleId'] as int?,
      expenseId: json['expenseId'] as int?,
      userId: json['userId'] as int,
      recipientId: json['recipientId'] as int,
      sourceType: ObligationSourceType.fromString(json['sourceType'] as String),
      amountDue: json['amountDue'] as int,
      amountPaid: json['amountPaid'] as int,
      currency: Currency.fromString(json['currency'] as String),
      status: ObligationStatus.fromString(json['status'] as String),
      dueAt: DateTime.parse(json['dueAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Used for create request bodies.
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'recipientId': recipientId,
        'sourceType': sourceType.value,
        'amountDue': amountDue,
        'currency': currency.value,
        'dueAt': dueAt.toIso8601String(),
        if (subscriptionCycleId != null) 'subscriptionCycleId': subscriptionCycleId,
        if (expenseId != null) 'expenseId': expenseId,
      };

  /// Used for update request bodies (only mutable fields).
  Map<String, dynamic> toUpdateJson() => {
        'amountPaid': amountPaid,
        'status': status.value,
      };
}
