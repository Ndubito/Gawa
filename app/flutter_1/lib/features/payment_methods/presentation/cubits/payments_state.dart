import 'package:flutter_1/features/payment_methods/domain/entities/payment_model.dart';

abstract class PaymentsState {}

class PaymentsInitial extends PaymentsState {}

class PaymentsLoading extends PaymentsState {}

class PaymentsLoaded extends PaymentsState {
  final List<PaymentModel> payments;
  PaymentsLoaded(this.payments);
}

class PaymentsError extends PaymentsState {
  final String message;
  PaymentsError(this.message);
}
