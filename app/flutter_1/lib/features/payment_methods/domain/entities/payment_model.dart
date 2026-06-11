import 'package:flutter_1/core/enums.dart';

class PaymentModel {
  final int id;
  final int obligationId;
  final int payerId;
  final int amount;
  final Currency currency;
  final PaymentStatus status;
  final String? paymentMethod;
  final String? idempotencyKey;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentModel({
    required this.id,
    required this.obligationId,
    required this.payerId,
    required this.amount,
    required this.currency,
    required this.status,
    this.paymentMethod,
    this.idempotencyKey,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as int,
      obligationId: json['obligationId'] as int,
      payerId: json['payerId'] as int,
      amount: json['amount'] as int,
      currency: Currency.fromString(json['currency'] as String),
      status: PaymentStatus.fromString(json['status'] as String),
      paymentMethod: json['paymentMethod'] as String?,
      idempotencyKey: json['idempotencyKey'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Used for create request bodies.
  Map<String, dynamic> toJson() => {
        'obligationId': obligationId,
        'payerId': payerId,
        'amount': amount,
        'currency': currency.value,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
        if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
      };
}
