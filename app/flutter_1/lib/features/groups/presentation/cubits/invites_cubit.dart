import 'package:flutter_1/features/groups/domain/repos/groups_repo.dart';
import 'package:flutter_1/features/groups/presentation/cubits/invites_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InvitesCubit extends Cubit<InvitesState> {
  final GroupsRepo groupsRepo;

  InvitesCubit({required this.groupsRepo}) : super(InvitesInitial());

  //load the signed-in user's pending invitations
  Future<void> loadInvites() async {
    try {
      emit(InvitesLoading());
      final invites = await groupsRepo.getInvites();
      emit(InvitesLoaded(invites));
    } catch (e) {
      emit(InvitesError(e.toString()));
    }
  }

  //accept, then drop the invite from the list.
  //Errors propagate so the page can show them.
  Future<void> accept(int groupId) =>
      _respond(groupId, () => groupsRepo.acceptInvite(groupId));

  Future<void> decline(int groupId) =>
      _respond(groupId, () => groupsRepo.declineInvite(groupId));

  Future<void> _respond(int groupId, Future<void> Function() call) async {
    final current = state;
    if (current is! InvitesLoaded) return;

    emit(
      InvitesLoaded(
        current.invites,
        responding: {...current.responding, groupId},
      ),
    );
    try {
      await call();
      emit(
        InvitesLoaded(
          current.invites.where((i) => i.groupId != groupId).toList(),
          responding: current.responding,
        ),
      );
    } catch (_) {
      emit(InvitesLoaded(current.invites, responding: current.responding));
      rethrow;
    }
  }
}
