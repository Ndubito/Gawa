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

  /// Used for create request bodies.
  Map<String, dynamic> toJson() => {
        'groupId': groupId,
        'recipientId': recipientId,
        'organizerId': organizerId,
        'name': name,
        'amountCents': amountCents,
        'currency': currency.value,
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
