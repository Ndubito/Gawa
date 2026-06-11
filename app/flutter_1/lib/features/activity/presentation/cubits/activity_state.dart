import 'package:flutter_1/features/activity/domain/entities/transaction_model.dart';

abstract class ActivityState {}

class ActivityInitial extends ActivityState {}

class ActivityLoading extends ActivityState {}

class ActivityLoaded extends ActivityState {
  final List<TransactionModel> transactions;
  ActivityLoaded(this.transactions);
}

class ActivityError extends ActivityState {
  final String message;
  ActivityError(this.message);
}
