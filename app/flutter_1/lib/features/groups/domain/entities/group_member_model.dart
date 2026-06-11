class GroupMemberModel {
  final int groupId;
  final int userId;
  final String? role;

  const GroupMemberModel({
    required this.groupId,
    required this.userId,
    this.role,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      groupId: json['groupId'] as int,
      userId: json['userId'] as int,
      role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'groupId': groupId,
        'userId': userId,
        if (role != null) 'role': role,
      };
}
