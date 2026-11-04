import 'package:flutter_1/core/enums.dart';

class SubscriptionModel {
  final int id;
  final int groupId;
  final int recipientId;
  final int organizerId;
  final String name;
  final String? description;
  final int amountCents;
  final Currency currency;
  final SubscriptionSchedule schedule;
  final int graceHours;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubscriptionModel({
    required this.id,
    required this.groupId,
    required this.recipientId,
    required this.organizerId,
    required this.name,
    this.description,
    required this.amountCents,
    required this.currency,
    required this.schedule,
    required this.graceHours,
    required this.status,
    required this.startDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as int,
      groupId: json['groupId'] as int,
      recipientId: json['recipientId'] as int,
      organizerId: json['organizerId'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      amountCents: json['amountCents'] as int,
      currency: Currency.fromString(json['currency'] as String),
      schedule: SubscriptionSchedule.fromString(json['schedule'] as String),
      graceHours: json['graceHours'] as int,
      status: SubscriptionStatus.fromString(json['status'] as String),
      startDate: DateTime.parse(json['startDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Total bill in whole-currency units (KES), e.g. 150000 cents -> 1500.0.
  double get amountValue => amountCents / 100;

  /// Each member's equal share. Falls back to the full amount when there are
  /// no members to divide between.
  double sharePerMember(int memberCount) =>
      memberCount > 0 ? amountValue / memberCount : amountValue;

  bool get isActive => status == SubscriptionStatus.active;

  /// Create request body. recipient/organizer are derived from the auth token
  /// on the backend, and currency/status default server-side — so they are
  /// deliberately omitted (the API rejects unexpected fields).
  Map<String, dynamic> toCreateJson() => {
        'groupId': groupId,
        'name': name,
        'amountCents': amountCents,
        'schedule': schedule.value,
        'graceHours': graceHours,
        'startDate': startDate.toIso8601String(),
        if (description != null) 'description': description,
      };

  /// Used for update request bodies (only mutable fields).
  Map<String, dynamic> toUpdateJson() => {
        'name': name,
        'amountCents': amountCents,
        'graceHours': graceHours,
        'status': status.value,
        if (description != null) 'description': description,
      };
}
