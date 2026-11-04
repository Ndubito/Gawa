import 'package:flutter_1/features/expenses/domain/entities/expense_split_model.dart';

/// A one-off cost someone in the group paid and split with others.
/// The payer is always whoever logged it.
class ExpenseModel {
  final int id;
  final int groupId;
  final int payerId;
  final String name;
  final String? description;
  final int totalAmountCents;
  final DateTime dueAt;
  final DateTime createdAt;
  final List<ExpenseSplitModel> splits;

  const ExpenseModel({
    required this.id,
    required this.groupId,
    required this.payerId,
    required this.name,
    this.description,
    required this.totalAmountCents,
    required this.dueAt,
    required this.createdAt,
    required this.splits,
  });

  bool isPaidBy(int userId) => payerId == userId;

  /// What [userId] owes the payer, or null if they don't owe anything.
  int? amountOwedBy(int userId) {
    if (userId == payerId) return null;
    return splits.where((s) => s.userId == userId).firstOrNull?.amountCents;
  }

  /// Everyone else's shares combined — what the payer is owed.
  int get amountOwedToPayer => splits
      .where((s) => s.userId != payerId)
      .fold(0, (sum, s) => sum + s.amountCents);

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as int,
      groupId: json['groupId'] as int,
      payerId: json['payerId'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      totalAmountCents: json['totalAmountCents'] as int,
      dueAt: DateTime.parse(json['dueAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      splits: (json['splits'] as List)
          .cast<Map<String, dynamic>>()
          .map(ExpenseSplitModel.fromJson)
          .toList(),
    );
  }
}
