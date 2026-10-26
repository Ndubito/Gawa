import 'package:flutter_1/features/subscriptions/domain/repos/subscriptions_repo.dart';
import 'package:flutter_1/features/subscriptions/presentation/cubits/subscriptions_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Backs the standalone Subscriptions tab: a read-only aggregate of every
/// subscription across the groups the user owns or belongs to.
class SubscriptionsCubit extends Cubit<SubscriptionsState> {
  final SubscriptionsRepo subscriptionsRepo;

  SubscriptionsCubit({required this.subscriptionsRepo}) : super(SubscriptionsInitial());

  Future<void> loadMine() async {
    try {
      emit(SubscriptionsLoading());
      final subscriptions = await subscriptionsRepo.getMySubscriptions();
      emit(SubscriptionsLoaded(subscriptions));
    } catch (e) {
      emit(SubscriptionsError(e.toString()));
    }
  }

  Future<void> loadGroupSubscriptions(int groupId) async {
    try {
      emit(SubscriptionsLoading());
      final subscriptions = await subscriptionsRepo.getGroupSubscriptions(groupId);
      emit(SubscriptionsLoaded(subscriptions));
    } catch (e) {
      emit(SubscriptionsError(e.toString()));
    }
  }
}
