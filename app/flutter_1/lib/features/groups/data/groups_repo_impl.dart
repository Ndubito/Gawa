import 'package:flutter_1/features/groups/domain/entities/group_member_model.dart';
import 'package:flutter_1/features/groups/domain/entities/group_model.dart';
import 'package:flutter_1/features/groups/domain/repos/groups_repo.dart';
import 'package:flutter_1/core/network/api_client.dart';
import 'package:dio/dio.dart';

class GroupsRepoImpl extends GroupsRepo {

  final Dio _dio = ApiClient().dio;

  @override
  Future<GroupModel> createGroup(GroupModel group) =>
      throw UnimplementedError();

  //Get all groups
  @override
  Future<List<GroupModel>> getGroups() async {
    try {
      final res = await _dio.get('/groups');
      final data = (res.data as List).cast<Map<String, dynamic>>();
      return data.map(GroupModel.fromJson).toList();
    } on DioException catch (e) {
      // e.type tells you if it was a timeout, connection error, bad response, etc.
      throw Exception('Failed to fetch groups: ${e.message}');
    }
  }

  @override
  Future<GroupModel> getGroup(int groupId) => throw UnimplementedError();

  @override
  Future<List<GroupModel>> getUserGroups(int userId) =>
      throw UnimplementedError();

  @override
  Future<GroupModel> updateGroup(int groupId, GroupModel group) =>
      throw UnimplementedError();

  @override
  Future<void> deleteGroup(int groupId) => throw UnimplementedError();

  @override
  Future<void> addMember(int groupId, int userId, {String? role}) =>
      throw UnimplementedError();

  @override
  Future<void> removeMember(int groupId, int userId) =>
      throw UnimplementedError();

  @override
  Future<List<GroupMemberModel>> getMembers(int groupId) =>
      throw UnimplementedError();
}
