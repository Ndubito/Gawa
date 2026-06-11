import 'package:flutter_1/features/expenses/domain/entities/expense_model.dart';
import 'package:flutter_1/features/expenses/domain/entities/expense_split_model.dart';
import 'package:flutter_1/features/expenses/domain/repos/expenses_repo.dart';

class ExpensesRepoImpl extends ExpensesRepo {
  // TODO: inject ApiClient

  @override
  Future<ExpenseModel> createExpense(ExpenseModel expense) => throw UnimplementedError();

  @override
  Future<ExpenseModel> getExpense(int expenseId) => throw UnimplementedError();

  @override
  Future<List<ExpenseModel>> getGroupExpenses(int groupId) => throw UnimplementedError();

  @override
  Future<ExpenseModel> updateExpense(int expenseId, ExpenseModel expense) => throw UnimplementedError();

  @override
  Future<void> deleteExpense(int expenseId) => throw UnimplementedError();

  @override
  Future<List<ExpenseSplitModel>> getSplits(int expenseId) => throw UnimplementedError();
}
