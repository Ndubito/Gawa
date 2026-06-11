import 'package:flutter_1/core/enums.dart';

class SubscriptionMemberModel {
  final int userId;
  final int subscriptionId;
  final int shareValue;
  final ShareType shareType;

  const SubscriptionMemberModel({
    required this.userId,
    required this.subscriptionId,
    required this.shareValue,
    required this.shareType,
  });

  factory SubscriptionMemberModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionMemberModel(
      userId: json['userId'] as int,
      subscriptionId: json['subscriptionId'] as int,
      shareValue: json['shareValue'] as int,
      shareType: ShareType.fromString(json['shareType'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'subscriptionId': subscriptionId,
        'shareValue': shareValue,
        'shareType': shareType.value,
      };
}
