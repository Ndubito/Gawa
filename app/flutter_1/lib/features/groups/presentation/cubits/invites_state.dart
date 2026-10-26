import 'package:flutter_1/features/groups/domain/entities/group_invite_model.dart';

abstract class InvitesState {}

class InvitesInitial extends InvitesState {}

class InvitesLoading extends InvitesState {}

class InvitesLoaded extends InvitesState {
  final List<GroupInviteModel> invites;

  /// Group ids with an accept/decline request in flight.
  final Set<int> responding;

  InvitesLoaded(this.invites, {this.responding = const {}});
}

class InvitesError extends InvitesState {
  final String message;
  InvitesError(this.message);
}
