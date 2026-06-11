import 'package:flutter_1/features/expenses/domain/entities/expense_model.dart';
import 'package:flutter_1/features/expenses/domain/entities/expense_split_model.dart';

abstract class ExpensesRepo {
  Future<ExpenseModel> createExpense(ExpenseModel expense);
  Future<ExpenseModel> getExpense(int expenseId);
  Future<List<ExpenseModel>> getGroupExpenses(int groupId);
  Future<ExpenseModel> updateExpense(int expenseId, ExpenseModel expense);
  Future<void> deleteExpense(int expenseId);
  Future<List<ExpenseSplitModel>> getSplits(int expenseId);
}
