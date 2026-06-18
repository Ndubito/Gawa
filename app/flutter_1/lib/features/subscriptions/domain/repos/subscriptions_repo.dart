import 'package:flutter_1/features/subscriptions/domain/entities/subscription_cycle_model.dart';
import 'package:flutter_1/features/subscriptions/domain/entities/subscription_member_model.dart';
import 'package:flutter_1/features/subscriptions/domain/entities/subscription_model.dart';

abstract class SubscriptionsRepo {
  Future<SubscriptionModel> createSubscription(SubscriptionModel subscription);
  Future<SubscriptionModel> getSubscription(int subscriptionId);
  Future<List<SubscriptionModel>> getGroupSubscriptions(int groupId);

  /// Every subscription across the groups the current user owns or belongs to.
  Future<List<SubscriptionModel>> getMySubscriptions();

  Future<SubscriptionModel> updateSubscription(int subscriptionId, SubscriptionModel subscription);
  Future<void> deleteSubscription(int subscriptionId);

  // Cycles & per-member shares arrive with the obligations feature; the
  // backend has no endpoints for these yet.
  Future<List<SubscriptionMemberModel>> getMembers(int subscriptionId);
  Future<List<SubscriptionCycleModel>> getCycles(int subscriptionId);
}
