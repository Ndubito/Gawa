import 'package:flutter_1/core/enums.dart';

class SubscriptionCycleModel {
  final int id;
  final int subscriptionId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime dueAt;
  final CycleStatus status;
  final DateTime updatedAt;

  const SubscriptionCycleModel({
    required this.id,
    required this.subscriptionId,
    required this.periodStart,
    required this.periodEnd,
    required this.dueAt,
    required this.status,
    required this.updatedAt,
  });

  factory SubscriptionCycleModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionCycleModel(
      id: json['id'] as int,
      subscriptionId: json['subscriptionId'] as int,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      dueAt: DateTime.parse(json['dueAt'] as String),
      status: CycleStatus.fromString(json['status'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'subscriptionId': subscriptionId,
        'periodStart': periodStart.toIso8601String(),
        'periodEnd': periodEnd.toIso8601String(),
        'dueAt': dueAt.toIso8601String(),
        'status': status.value,
      };
}
