import 'package:flutter_1/features/subscriptions/domain/entities/subscription_model.dart';

abstract class GroupSubscriptionsState {}

class GroupSubscriptionsInitial extends GroupSubscriptionsState {}

class GroupSubscriptionsLoading extends GroupSubscriptionsState {}

class GroupSubscriptionsLoaded extends GroupSubscriptionsState {
  final List<SubscriptionModel> subscriptions;
  GroupSubscriptionsLoaded(this.subscriptions);
}

class GroupSubscriptionsError extends GroupSubscriptionsState {
  final String message;
  GroupSubscriptionsError(this.message);
}
