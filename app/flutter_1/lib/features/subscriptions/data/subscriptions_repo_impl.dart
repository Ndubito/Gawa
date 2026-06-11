import 'package:flutter_1/features/subscriptions/domain/entities/subscription_cycle_model.dart';
import 'package:flutter_1/features/subscriptions/domain/entities/subscription_member_model.dart';
import 'package:flutter_1/features/subscriptions/domain/entities/subscription_model.dart';
import 'package:flutter_1/features/subscriptions/domain/repos/subscriptions_repo.dart';

class SubscriptionsRepoImpl extends SubscriptionsRepo {
  // TODO: inject ApiClient

  @override
  Future<SubscriptionModel> createSubscription(SubscriptionModel subscription) => throw UnimplementedError();

  @override
  Future<SubscriptionModel> getSubscription(int subscriptionId) => throw UnimplementedError();

  @override
  Future<List<SubscriptionModel>> getGroupSubscriptions(int groupId) => throw UnimplementedError();

  @override
  Future<SubscriptionModel> updateSubscription(int subscriptionId, SubscriptionModel subscription) => throw UnimplementedError();

  @override
  Future<void> deleteSubscription(int subscriptionId) => throw UnimplementedError();

  @override
  Future<List<SubscriptionMemberModel>> getMembers(int subscriptionId) => throw UnimplementedError();

  @override
  Future<List<SubscriptionCycleModel>> getCycles(int subscriptionId) => throw UnimplementedError();
}
