import 'package:flutter_1/features/activity/domain/entities/transaction_model.dart';

abstract class ActivityRepo {
  Future<TransactionModel> getTransaction(int transactionId);
  Future<List<TransactionModel>> getPaymentTransactions(int paymentId);
}
