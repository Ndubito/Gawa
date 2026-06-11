class GroupMemberModel {
  final int userId;
  final String? fullName;
  final String? phoneNumber;
  final String role;

  const GroupMemberModel({
    required this.userId,
    this.fullName,
    this.phoneNumber,
    required this.role,
  });

  bool get isOwner => role == 'owner';

  /// Best available display name — placeholder users are named
  /// after their phone number until they sign up.
  String get displayName =>
      (fullName != null && fullName!.isNotEmpty) ? fullName! : (phoneNumber ?? 'Member');

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      userId: json['userId'] as int,
      fullName: json['fullName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      role: json['role'] as String,
    );
  }
}
