import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_1/features/expenses/domain/repos/expenses_repo.dart';
import 'package:flutter_1/features/expenses/presentation/cubits/group_expenses_state.dart';

/// Expenses of a single group. Create/delete errors propagate so the UI can
/// show them where they happened.
class GroupExpensesCubit extends Cubit<GroupExpensesState> {
  final ExpensesRepo expensesRepo;
  final int groupId;

  GroupExpensesCubit({required this.expensesRepo, required this.groupId})
    : super(GroupExpensesInitial());

  Future<void> loadExpenses() async {
    try {
      emit(GroupExpensesLoading());
      final expenses = await expensesRepo.getGroupExpenses(groupId);
      emit(GroupExpensesLoaded(expenses));
    } catch (e) {
      emit(GroupExpensesError(e.toString()));
    }
  }

  Future<void> createExpense({
    required String name,
    String? description,
    required int totalAmountCents,
    required int dueInDays,
    required List<int> participantIds,
  }) async {
    await expensesRepo.createExpense(
      groupId: groupId,
      name: name,
      description: description,
      totalAmountCents: totalAmountCents,
      dueInDays: dueInDays,
      participantIds: participantIds,
    );
    await loadExpenses();
  }

  Future<void> deleteExpense(int expenseId) async {
    await expensesRepo.deleteExpense(expenseId);
    await loadExpenses();
  }
}
