import 'package:flutter_1/features/payment_methods/domain/entities/payment_model.dart';
import 'package:flutter_1/features/payment_methods/domain/repos/payments_repo.dart';

class PaymentsRepoImpl extends PaymentsRepo {
  // TODO: inject ApiClient

  @override
  Future<PaymentModel> createPayment(PaymentModel payment) => throw UnimplementedError();

  @override
  Future<PaymentModel> getPayment(int paymentId) => throw UnimplementedError();

  @override
  Future<List<PaymentModel>> getObligationPayments(int obligationId) => throw UnimplementedError();
}
