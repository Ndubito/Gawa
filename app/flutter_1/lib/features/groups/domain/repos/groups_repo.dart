import 'package:flutter_1/features/groups/domain/entities/group_model.dart';
import 'package:flutter_1/features/groups/domain/entities/group_member_model.dart';

abstract class GroupsRepo {
  Future<GroupModel> createGroup(GroupModel group);
  Future<List<GroupModel>> getGroups();
  Future<GroupModel> getGroup(int groupId);
  Future<List<GroupModel>> getUserGroups(int userId);
  Future<GroupModel> updateGroup(int groupId, GroupModel group);
  Future<void> deleteGroup(int groupId);
  Future<void> addMember(int groupId, int userId, {String? role});
  Future<void> removeMember(int groupId, int userId);
  Future<List<GroupMemberModel>> getMembers(int groupId);
}
