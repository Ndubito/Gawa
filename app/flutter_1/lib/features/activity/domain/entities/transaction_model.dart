class TransactionModel {
  final int id;
  final int paymentId;
  final String provider;
  final String providerReference;
  final String providerName;
  final Map<String, dynamic> rawResponse;
  final String status;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.paymentId,
    required this.provider,
    required this.providerReference,
    required this.providerName,
    required this.rawResponse,
    required this.status,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int,
      paymentId: json['paymentId'] as int,
      provider: json['provider'] as String,
      providerReference: json['providerReference'] as String,
      providerName: json['providerName'] as String,
      rawResponse: Map<String, dynamic>.from(json['rawResponse'] as Map),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'paymentId': paymentId,
        'provider': provider,
        'providerReference': providerReference,
        'providerName': providerName,
        'rawResponse': rawResponse,
        'status': status,
      };
}
