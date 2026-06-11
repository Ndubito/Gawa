import 'package:flutter_1/features/groups/domain/entities/group_model.dart';
import 'package:flutter_1/features/groups/domain/entities/group_member_model.dart';
import 'package:flutter_1/features/groups/domain/repos/groups_repo.dart';
import 'package:flutter_1/core/network/api_client.dart';
import 'package:dio/dio.dart';

class GroupsRepoImpl extends GroupsRepo {
  final Dio _dio = ApiClient().dio;

  //Create a group (owner comes from the auth token on the backend)
  @override
  Future<GroupModel> createGroup(String name, {String? description}) async {
    try {
      final res = await _dio.post('/groups', data: {
        'name': name,
        if (description != null && description.isNotEmpty)
          'description': description,
      });
      return GroupModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to create group: ${e.message}');
    }
  }

  //Get all of the current user's groups
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

  //Get a single group
  @override
  Future<GroupModel> getGroup(int groupId) async {
    try {
      final res = await _dio.get('/groups/$groupId');
      return GroupModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to fetch group: ${e.message}');
    }
  }

  //Update a group's name/description
  @override
  Future<GroupModel> updateGroup(
    int groupId, {
    String? name,
    String? description,
  }) async {
    try {
      final res = await _dio.patch('/groups/$groupId', data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
      });
      return GroupModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to update group: ${e.message}');
    }
  }

  //Delete (soft) a group
  @override
  Future<void> deleteGroup(int groupId) async {
    try {
      await _dio.delete('/groups/$groupId');
    } on DioException catch (e) {
      throw Exception('Failed to delete group: ${e.message}');
    }
  }

  //List the group's members (owner first)
  @override
  Future<List<GroupMemberModel>> getMembers(int groupId) async {
    try {
      final res = await _dio.get('/groups/$groupId/members');
      final data = (res.data as List).cast<Map<String, dynamic>>();
      return data.map(GroupMemberModel.fromJson).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch members: ${e.message}');
    }
  }

  //Add a member by phone number (creates a placeholder user if unknown)
  @override
  Future<GroupMemberModel> addMember(int groupId, String phoneNumber) async {
    try {
      final res = await _dio.post(
        '/groups/$groupId/members',
        data: {'phoneNumber': phoneNumber},
      );
      return GroupMemberModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // Surface the backend's message (e.g. "already a member") when present
      final message = e.response?.data is Map
          ? (e.response!.data['message']?.toString() ?? e.message)
          : e.message;
      throw Exception('Failed to add member: $message');
    }
  }

  //Remove a member from the group
  @override
  Future<void> removeMember(int groupId, int userId) async {
    try {
      await _dio.delete('/groups/$groupId/members/$userId');
    } on DioException catch (e) {
      throw Exception('Failed to remove member: ${e.message}');
    }
  }
}
