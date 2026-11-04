import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_1/core/enums.dart';
import 'package:flutter_1/features/subscriptions/domain/entities/subscription_model.dart';
import 'package:flutter_1/features/subscriptions/domain/repos/subscriptions_repo.dart';
import 'package:flutter_1/features/subscriptions/presentation/cubits/group_subscriptions_state.dart';

/// Manages the subscriptions of a single group (owner-created), mirroring
/// GroupMembersCubit. Create/delete errors propagate so the UI can show them.
class GroupSubscriptionsCubit extends Cubit<GroupSubscriptionsState> {
  final SubscriptionsRepo subscriptionsRepo;
  final int groupId;

  GroupSubscriptionsCubit({required this.subscriptionsRepo, required this.groupId})
      : super(GroupSubscriptionsInitial());

  Future<void> loadSubscriptions() async {
    try {
      emit(GroupSubscriptionsLoading());
      final subs = await subscriptionsRepo.getGroupSubscriptions(groupId);
      emit(GroupSubscriptionsLoaded(subs));
    } catch (e) {
      emit(GroupSubscriptionsError(e.toString()));
    }
  }

  /// Create a monthly subscription then refresh. recipient/organizer are set
  /// server-side from the token, so the placeholder ids below are never sent
  /// (see SubscriptionModel.toCreateJson).
  Future<void> createSubscription({
    required String name,
    required int amountCents,
    required DateTime startDate,
    String? description,
    int graceHours = 48,
  }) async {
    final now = DateTime.now();
    final draft = SubscriptionModel(
      id: 0,
      groupId: groupId,
      recipientId: 0,
      organizerId: 0,
      name: name,
      description: (description != null && description.isNotEmpty) ? description : null,
      amountCents: amountCents,
      currency: Currency.kes,
      schedule: SubscriptionSchedule.monthly,
      graceHours: graceHours,
      status: SubscriptionStatus.active,
      startDate: startDate,
      createdAt: now,
      updatedAt: now,
    );
    await subscriptionsRepo.createSubscription(draft);
    await loadSubscriptions();
  }

  Future<void> deleteSubscription(int subscriptionId) async {
    await subscriptionsRepo.deleteSubscription(subscriptionId);
    await loadSubscriptions();
  }
}
