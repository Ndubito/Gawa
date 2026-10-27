import 'package:flutter_1/features/expenses/domain/entities/expense_model.dart';

abstract class GroupExpensesState {}

class GroupExpensesInitial extends GroupExpensesState {}

class GroupExpensesLoading extends GroupExpensesState {}

class GroupExpensesLoaded extends GroupExpensesState {
  final List<ExpenseModel> expenses;
  GroupExpensesLoaded(this.expenses);
}

class GroupExpensesError extends GroupExpensesState {
  final String message;
  GroupExpensesError(this.message);
}
