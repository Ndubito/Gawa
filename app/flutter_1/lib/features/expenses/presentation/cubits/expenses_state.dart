import 'package:flutter_1/features/expenses/domain/entities/expense_model.dart';

abstract class ExpensesState {}

class ExpensesInitial extends ExpensesState {}

class ExpensesLoading extends ExpensesState {}

class ExpensesLoaded extends ExpensesState {
  final List<ExpenseModel> expenses;
  ExpensesLoaded(this.expenses);
}

class ExpensesError extends ExpensesState {
  final String message;
  ExpensesError(this.message);
}
