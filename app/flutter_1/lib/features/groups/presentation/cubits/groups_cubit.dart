import 'package:flutter_1/features/groups/domain/repos/groups_repo.dart';
import 'package:flutter_1/features/groups/presentation/cubits/groups_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupsCubit extends Cubit<GroupsState> {
  final GroupsRepo groupsRepo;

  GroupsCubit({required this.groupsRepo}) : super(GroupsInitial());

  //load the current user's groups
  Future<void> loadGroups() async {
    try {
      emit(GroupsLoading());
      final groups = await groupsRepo.getGroups();
      emit(GroupsLoaded(groups));
    } catch (e) {
      emit(GroupsError(e.toString()));
    }
  }

  //create a group then refresh the list.
  //Errors propagate to the caller so the page can show them inline.
  Future<void> createGroup(String name, {String? description}) async {
    await groupsRepo.createGroup(name, description: description);
    await loadGroups();
  }

  //delete a group then refresh the list.
  Future<void> deleteGroup(int groupId) async {
    await groupsRepo.deleteGroup(groupId);
    await loadGroups();
  }
}
