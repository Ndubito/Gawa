class ExpenseModel {
  final int id;
  final int organizerId;
  final int? groupId;
  final int payerId;
  final int totalAmount;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseModel({
    required this.id,
    required this.organizerId,
    this.groupId,
    required this.payerId,
    required this.totalAmount,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as int,
      organizerId: json['organizerId'] as int,
      groupId: json['groupId'] as int?,
      payerId: json['payerId'] as int,
      totalAmount: json['totalAmount'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Used for create request bodies.
  Map<String, dynamic> toJson() => {
        'organizerId': organizerId,
        'payerId': payerId,
        'totalAmount': totalAmount,
        'name': name,
        if (groupId != null) 'groupId': groupId,
        if (description != null) 'description': description,
      };

  /// Used for update request bodies (only mutable fields).
  Map<String, dynamic> toUpdateJson() => {
        'name': name,
        'totalAmount': totalAmount,
        if (description != null) 'description': description,
      };
}
