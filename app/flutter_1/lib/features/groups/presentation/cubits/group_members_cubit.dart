import 'package:flutter_1/features/groups/domain/repos/groups_repo.dart';
import 'package:flutter_1/features/groups/presentation/cubits/group_members_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupMembersCubit extends Cubit<GroupMembersState> {
  final GroupsRepo groupsRepo;
  final int groupId;

  GroupMembersCubit({required this.groupsRepo, required this.groupId})
      : super(GroupMembersInitial());

  //load the group's members (owner first)
  Future<void> loadMembers() async {
    try {
      emit(GroupMembersLoading());
      final members = await groupsRepo.getMembers(groupId);
      emit(GroupMembersLoaded(members));
    } catch (e) {
      emit(GroupMembersError(e.toString()));
    }
  }

  //add a member by phone then refresh.
  //Errors propagate so the page can show them inline.
  Future<void> addMember(String phoneNumber) async {
    await groupsRepo.addMember(groupId, phoneNumber);
    await loadMembers();
  }

  //remove a member then refresh.
  Future<void> removeMember(int userId) async {
    await groupsRepo.removeMember(groupId, userId);
    await loadMembers();
  }
}
