import 'package:flutter_1/features/groups/domain/repos/groups_repo.dart';
import 'package:flutter_1/features/groups/presentation/cubits/groups_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupsCubit extends Cubit<GroupsState> {
  final GroupsRepo groupsRepo;

  GroupsCubit({required this.groupsRepo}) : super(GroupsInitial());

  Future<void> loadGroups(int userId) async {
    try {
      emit(GroupsLoading());
      final groups = await groupsRepo.getUserGroups(userId);
      emit(GroupsLoaded(groups));
    } catch (e) {
      emit(GroupsError(e.toString()));
    }
  }
}
