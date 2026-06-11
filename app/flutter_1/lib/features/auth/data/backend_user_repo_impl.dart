import 'package:dio/dio.dart';
import 'package:flutter_1/core/network/api_client.dart';
import 'package:flutter_1/features/auth/domain/entities/user_model.dart';
import 'package:flutter_1/features/auth/domain/repos/backend_user_repo.dart';

class BackendUserRepoImpl extends BackendUserRepo {
  final Dio _dio = ApiClient().dio;

  @override
  Future<UserModel> getMe() async {
    try {
      final res = await _dio.get('/users/me');
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to fetch backend user: ${e.message}');
    }
  }
}
