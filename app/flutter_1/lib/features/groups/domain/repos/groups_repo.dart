/*
GROUPS REPOSITORY - Outlines the group operations on this app.
The backend derives the requester from the Firebase token, so no userId
is ever sent for access control — you only see groups you own or have joined.
*/

import 'package:flutter_1/features/groups/domain/entities/group_model.dart';
import 'package:flutter_1/features/groups/domain/entities/group_member_model.dart';
import 'package:flutter_1/features/groups/domain/entities/group_invite_model.dart';

abstract class GroupsRepo {
  Future<GroupModel> createGroup(String name, {String? description});
  Future<List<GroupModel>> getGroups();
  Future<GroupModel> getGroup(int groupId);
  Future<GroupModel> updateGroup(int groupId, {String? name, String? description});
  Future<void> deleteGroup(int groupId);

  // Membership (owner-managed; phone number in E.164 format).
  // Adding someone sends an invite they must accept.
  Future<List<GroupMemberModel>> getMembers(int groupId);
  Future<GroupMemberModel> addMember(int groupId, String phoneNumber);
  Future<void> removeMember(int groupId, int userId);

  // Invitations addressed to the signed-in user
  Future<List<GroupInviteModel>> getInvites();
  Future<void> acceptInvite(int groupId);
  Future<void> declineInvite(int groupId);
}
