import 'package:flutter_1/core/enums.dart';

class ExpenseSplitModel {
  final int expenseId;
  final int userId;
  final int shareValue;
  final ShareType shareType;

  const ExpenseSplitModel({
    required this.expenseId,
    required this.userId,
    required this.shareValue,
    required this.shareType,
  });

  factory ExpenseSplitModel.fromJson(Map<String, dynamic> json) {
    return ExpenseSplitModel(
      expenseId: json['expenseId'] as int,
      userId: json['userId'] as int,
      shareValue: json['shareValue'] as int,
      shareType: ShareType.fromString(json['shareType'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'expenseId': expenseId,
        'userId': userId,
        'shareValue': shareValue,
        'shareType': shareType.value,
      };
}
