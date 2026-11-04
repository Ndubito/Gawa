/// One person's share of an expense, in cents.
class ExpenseSplitModel {
  final int userId;
  final int amountCents;

  const ExpenseSplitModel({required this.userId, required this.amountCents});

  factory ExpenseSplitModel.fromJson(Map<String, dynamic> json) {
    return ExpenseSplitModel(
      userId: json['userId'] as int,
      amountCents: json['amountCents'] as int,
    );
  }
}
