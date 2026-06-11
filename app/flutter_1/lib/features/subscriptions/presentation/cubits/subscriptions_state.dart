import 'package:flutter_1/features/subscriptions/domain/entities/subscription_model.dart';

abstract class SubscriptionsState {}

class SubscriptionsInitial extends SubscriptionsState {}

class SubscriptionsLoading extends SubscriptionsState {}

class SubscriptionsLoaded extends SubscriptionsState {
  final List<SubscriptionModel> subscriptions;
  SubscriptionsLoaded(this.subscriptions);
}

class SubscriptionsError extends SubscriptionsState {
  final String message;
  SubscriptionsError(this.message);
}
