import 'package:dio/dio.dart';
import 'package:flutter_1/core/network/api_client.dart';
import 'package:flutter_1/features/expenses/domain/entities/expense_model.dart';
import 'package:flutter_1/features/expenses/domain/repos/expenses_repo.dart';

class ExpensesRepoImpl extends ExpensesRepo {
  final Dio _dio = ApiClient().dio;

  @override
  Future<List<ExpenseModel>> getGroupExpenses(int groupId) async {
    try {
      final res = await _dio.get('/expenses/group/$groupId');
      final data = (res.data as List).cast<Map<String, dynamic>>();
      return data.map(ExpenseModel.fromJson).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch expenses: ${e.message}');
    }
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
    try {
      final res = await _dio.post(
        '/expenses',
        data: {
          'groupId': groupId,
          'name': name,
          if (description != null && description.isNotEmpty)
            'description': description,
          'totalAmountCents': totalAmountCents,
          'dueInDays': dueInDays,
          'participantIds': participantIds,
        },
      );
      return ExpenseModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // Surface validation messages like "amount is too small to split"
      final message = e.response?.data is Map
          ? (e.response!.data['message']?.toString() ?? e.message)
          : e.message;
      throw Exception('Failed to add expense: $message');
    }
  }

  @override
  Future<void> deleteExpense(int expenseId) async {
    try {
      await _dio.delete('/expenses/$expenseId');
    } on DioException catch (e) {
      throw Exception('Failed to delete expense: ${e.message}');
    }
  }
}
