import 'package:flutter_1/features/subscriptions/domain/entities/subscription_cycle_model.dart';
import 'package:flutter_1/features/subscriptions/domain/entities/subscription_member_model.dart';
import 'package:flutter_1/features/subscriptions/domain/entities/subscription_model.dart';

abstract class SubscriptionsRepo {
  Future<SubscriptionModel> createSubscription(SubscriptionModel subscription);
  Future<SubscriptionModel> getSubscription(int subscriptionId);
  Future<List<SubscriptionModel>> getGroupSubscriptions(int groupId);
  Future<SubscriptionModel> updateSubscription(int subscriptionId, SubscriptionModel subscription);
  Future<void> deleteSubscription(int subscriptionId);
  Future<List<SubscriptionMemberModel>> getMembers(int subscriptionId);
  Future<List<SubscriptionCycleModel>> getCycles(int subscriptionId);
}
