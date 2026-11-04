/// A pending invitation to join a group. Invitees only see this summary
/// until they accept.
class GroupInviteModel {
  final int groupId;
  final String groupName;
  final String? groupDescription;
  final String invitedByName;

  const GroupInviteModel({
    required this.groupId,
    required this.groupName,
    this.groupDescription,
    required this.invitedByName,
  });

  factory GroupInviteModel.fromJson(Map<String, dynamic> json) {
    return GroupInviteModel(
      groupId: json['groupId'] as int,
      groupName: json['groupName'] as String,
      groupDescription: json['groupDescription'] as String?,
      invitedByName: json['invitedByName'] as String,
    );
  }
}
