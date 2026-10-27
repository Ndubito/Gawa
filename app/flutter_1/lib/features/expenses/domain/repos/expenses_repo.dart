/*
EXPENSES REPOSITORY - one-off costs split within a group.
The backend makes the signed-in user the payer, so no payer id is ever sent.
*/

import 'package:flutter_1/features/expenses/domain/entities/expense_model.dart';

abstract class ExpensesRepo {
  Future<List<ExpenseModel>> getGroupExpenses(int groupId);

  Future<ExpenseModel> createExpense({
    required int groupId,
    required String name,
    String? description,
    required int totalAmountCents,
    required int dueInDays,
    required List<int> participantIds,
  });

  /// Payer only. Cancels every unpaid share.
  Future<void> deleteExpense(int expenseId);
}
