import 'package:dio/dio.dart';
import 'package:flutter_1/core/network/api_client.dart';
import 'package:flutter_1/features/obligations/domain/entities/obligation_model.dart';
import 'package:flutter_1/features/obligations/domain/repos/obligations_repo.dart';

class ObligationsRepoImpl extends ObligationsRepo {
  final Dio _dio = ApiClient().dio;

  @override
  Future<List<ObligationModel>> getMyBills() async {
    try {
      final res = await _dio.get('/obligations');
      final data = (res.data as List).cast<Map<String, dynamic>>();
      return data.map(ObligationModel.fromJson).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch bills: ${e.message}');
    }
  }
}
