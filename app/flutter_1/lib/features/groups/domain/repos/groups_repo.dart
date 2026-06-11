/*
GROUPS REPOSITORY - Outlines the group operations on this app.
The backend derives the owner from the Firebase token, so no userId
is ever sent — you only ever see and manage your own groups.
*/

import 'package:flutter_1/features/groups/domain/entities/group_model.dart';
import 'package:flutter_1/features/groups/domain/entities/group_member_model.dart';

abstract class GroupsRepo {
  Future<GroupModel> createGroup(String name, {String? description});
  Future<List<GroupModel>> getGroups();
  Future<GroupModel> getGroup(int groupId);
  Future<GroupModel> updateGroup(int groupId, {String? name, String? description});
  Future<void> deleteGroup(int groupId);

  // Membership (owner-managed; phone number in E.164 format)
  Future<List<GroupMemberModel>> getMembers(int groupId);
  Future<GroupMemberModel> addMember(int groupId, String phoneNumber);
  Future<void> removeMember(int groupId, int userId);
}
