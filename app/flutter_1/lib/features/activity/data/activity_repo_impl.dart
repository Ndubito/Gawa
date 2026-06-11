import 'package:flutter_1/features/activity/domain/entities/transaction_model.dart';
import 'package:flutter_1/features/activity/domain/repos/activity_repo.dart';

class ActivityRepoImpl extends ActivityRepo {
  // TODO: inject ApiClient

  @override
  Future<TransactionModel> getTransaction(int transactionId) => throw UnimplementedError();

  @override
  Future<List<TransactionModel>> getPaymentTransactions(int paymentId) => throw UnimplementedError();
}
