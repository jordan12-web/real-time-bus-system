import 'package:dio/dio.dart';

import '../core/api/dio_client.dart';
import '../core/json_adapter.dart';

/// Auth API client — mirrors OpenAPI `/auth/*` paths.
class AuthService {
  final DioClient _client;

  AuthService(this._client);

  Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      final response = await _client.sendWithRetry(
        () => _client.dio.post<Map<String, dynamic>>(
          '/auth/signup',
          data: {
            'full_name': fullName,
            'email': email,
            'password': password,
            'phone_number': ?phoneNumber,
          },
        ),
      );
      return normalizeKeys(response.data ?? {});
    } on DioException catch (error) {
      throw _client.handleDioError(error);
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.sendWithRetry(
        () => _client.dio.post<Map<String, dynamic>>(
          '/auth/login',
          data: {'email': email, 'password': password},
        ),
      );
      return normalizeKeys(response.data ?? {});
    } on DioException catch (error) {
      throw _client.handleDioError(error);
    }
  }

  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      return normalizeKeys(response.data ?? {});
    } on DioException catch (error) {
      throw _client.handleDioError(error);
    }
  }

  Future<Map<String, dynamic>> me() async {
    try {
      final response = await _client.sendWithRetry(
        () => _client.dio.get<Map<String, dynamic>>('/auth/me'),
      );
      return normalizeKeys(response.data ?? {});
    } on DioException catch (error) {
      throw _client.handleDioError(error);
    }
  }
}
