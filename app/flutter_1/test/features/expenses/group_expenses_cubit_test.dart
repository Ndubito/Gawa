import 'package:flutter_1/core/money.dart';
import 'package:flutter_1/features/expenses/domain/entities/expense_model.dart';
import 'package:flutter_1/features/expenses/domain/entities/expense_split_model.dart';
import 'package:flutter_1/features/expenses/domain/repos/expenses_repo.dart';
import 'package:flutter_1/features/expenses/presentation/cubits/group_expenses_cubit.dart';
import 'package:flutter_1/features/expenses/presentation/cubits/group_expenses_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _me = 2;

/// In-memory fake that splits equally like the backend; set [failing] to
/// simulate the backend being down or rejecting a request.
class FakeExpensesRepo extends ExpensesRepo {
  final List<ExpenseModel> expenses = [];
  final List<Map<String, Object?>> created = [];
  bool failing = false;
  int _nextId = 1;

  void _maybeFail() {
    if (failing) throw Exception('backend unreachable');
  }

  @override
  Future<List<ExpenseModel>> getGroupExpenses(int groupId) async {
    _maybeFail();
    return expenses.where((e) => e.groupId == groupId).toList();
  }

  @override
  Future<ExpenseModel> createExpense({
    required int groupId,
    required String name,
    String? description,
    required int totalAmountCents,
    required int dueInDays,
    required List<int> participantIds,
  }) async {
    _maybeFail();
    created.add({
      'name': name,
      'totalAmountCents': totalAmountCents,
      'dueInDays': dueInDays,
      'participantIds': participantIds,
    });
    final share = totalAmountCents ~/ participantIds.length;
    final expense = ExpenseModel(
      id: _nextId++,
      groupId: groupId,
      payerId: _me,
      name: name,
      totalAmountCents: totalAmountCents,
      dueAt: DateTime.now().add(Duration(days: dueInDays)),
      createdAt: DateTime.now(),
      splits: [
        for (final id in participantIds)
          ExpenseSplitModel(userId: id, amountCents: share),
      ],
    );
    expenses.add(expense);
    return expense;
  }

  @override
  Future<void> deleteExpense(int expenseId) async {
    _maybeFail();
    expenses.removeWhere((e) => e.id == expenseId);
  }
}

void main() {
  group('GroupExpensesCubit', () {
    late FakeExpensesRepo repo;
    late GroupExpensesCubit cubit;

    setUp(() {
      repo = FakeExpensesRepo();
      cubit = GroupExpensesCubit(expensesRepo: repo, groupId: 10);
    });

    test('loadExpenses emits Loading then Loaded', () async {
      final emitted = <GroupExpensesState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.loadExpenses();
      await Future<void>.delayed(Duration.zero);

      expect(emitted.first, isA<GroupExpensesLoading>());
      expect(emitted.last, isA<GroupExpensesLoaded>());
      await sub.cancel();
    });

    test('loadExpenses emits Error when the repo fails', () async {
      repo.failing = true;
      await cubit.loadExpenses();
      expect(cubit.state, isA<GroupExpensesError>());
    });

    test('createExpense sends the split and reloads', () async {
      await cubit.createExpense(
        name: 'Dinner',
        totalAmountCents: 300000,
        dueInDays: 3,
        participantIds: [1, _me, 3],
      );

      expect(repo.created.single['participantIds'], [1, _me, 3]);
      final state = cubit.state as GroupExpensesLoaded;
      expect(state.expenses.single.name, 'Dinner');
    });

    test('createExpense propagates errors to the caller', () async {
      repo.failing = true;
      expect(
        () => cubit.createExpense(
          name: 'Doomed',
          totalAmountCents: 100,
          dueInDays: 3,
          participantIds: [1, _me],
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('deleteExpense removes it and reloads', () async {
      await cubit.createExpense(
        name: 'Taxi',
        totalAmountCents: 100000,
        dueInDays: 1,
        participantIds: [1, _me],
      );

      await cubit.deleteExpense(repo.expenses.single.id);

      expect((cubit.state as GroupExpensesLoaded).expenses, isEmpty);
    });
  });

  group('ExpenseModel', () {
    final expense = ExpenseModel.fromJson({
      'id': 7,
      'groupId': 10,
      'payerId': 2,
      'name': 'Dinner',
      'description': null,
      'totalAmountCents': 400000,
      'dueAt': '2026-11-08T06:00:00.000Z',
      'createdAt': '2026-11-05T17:00:00.000Z',
      'splits': [
        {'userId': 1, 'amountCents': 133333},
        {'userId': 2, 'amountCents': 133334},
        {'userId': 3, 'amountCents': 133333},
      ],
    });

    test('fromJson parses a backend expense with splits', () {
      expect(expense.splits, hasLength(3));
      expect(expense.dueAt.isUtc, isTrue);
    });

    test('knows what each person owes and what the payer is owed', () {
      expect(expense.amountOwedBy(1), 133333);
      expect(expense.amountOwedBy(2), isNull, reason: 'the payer owes nothing');
      expect(expense.amountOwedBy(99), isNull, reason: 'not in the split');
      expect(expense.amountOwedToPayer, 266666);
    });
  });

  test('formatKesCents shows whole shillings with separators', () {
    expect(formatKesCents(400000), '4,000');
    expect(formatKesCents(133333), '1,333');
    expect(formatKesCents(12345678), '123,457');
  });
}
