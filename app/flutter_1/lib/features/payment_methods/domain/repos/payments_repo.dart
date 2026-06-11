import 'package:flutter_1/features/payment_methods/domain/entities/payment_model.dart';

abstract class PaymentsRepo {
  Future<PaymentModel> createPayment(PaymentModel payment);
  Future<PaymentModel> getPayment(int paymentId);
  Future<List<PaymentModel>> getObligationPayments(int obligationId);
}
