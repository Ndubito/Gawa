class GroupMemberModel {
  final int userId;
  final String? fullName;
  final String? phoneNumber;
  final String role;

  /// 'ACTIVE' once they've accepted, 'INVITED' while the invite is pending.
  final String status;

  const GroupMemberModel({
    required this.userId,
    this.fullName,
    this.phoneNumber,
    required this.role,
    this.status = 'ACTIVE',
  });

  bool get isOwner => role == 'owner';

  bool get isPending => status == 'INVITED';

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
      status: json['status'] as String,
    );
  }
}
