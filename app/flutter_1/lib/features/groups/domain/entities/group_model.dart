class GroupModel {
  final int id;
  final String name;
  final String? description;
  final int ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GroupModel({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      ownerId: json['ownerId'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

}
