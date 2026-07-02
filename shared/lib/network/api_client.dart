import 'package:dio/dio.dart';

class ApiClient {
  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:8080/api/v1', // Should be configured via Env
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add Auth Token here using Secure Storage
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Handle global errors, token refresh etc.
          return handler.next(e);
        },
      ),
    );

    return dio;
  }
}
