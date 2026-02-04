import 'package:dio/dio.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() { 
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:8000',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ) 
    );
  }
}