import 'package:flutter_1/features/expenses/domain/repos/expenses_repo.dart';
import 'package:flutter_1/features/expenses/presentation/cubits/expenses_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpensesCubit extends Cubit<ExpensesState> {
  final ExpensesRepo expensesRepo;

  ExpensesCubit({required this.expensesRepo}) : super(ExpensesInitial());

  Future<void> loadGroupExpenses(int groupId) async {
    try {
      emit(ExpensesLoading());
      final expenses = await expensesRepo.getGroupExpenses(groupId);
      emit(ExpensesLoaded(expenses));
    } catch (e) {
      emit(ExpensesError(e.toString()));
    }
  }
}
