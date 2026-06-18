import 'package:flutter_1/features/groups/domain/entities/group_member_model.dart';

abstract class GroupMembersState {}

class GroupMembersInitial extends GroupMembersState {}

class GroupMembersLoading extends GroupMembersState {}

class GroupMembersLoaded extends GroupMembersState {
  final List<GroupMemberModel> members;
  GroupMembersLoaded(this.members);
}

class GroupMembersError extends GroupMembersState {
  final String message;
  GroupMembersError(this.message);
}
