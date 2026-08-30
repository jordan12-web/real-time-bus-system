import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/config.dart';

class DriverUser {
  final String id;
  final String fullName;
  final String email;
  final String role;

  DriverUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory DriverUser.fromJson(Map<String, dynamic> json) {
    return DriverUser(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class AuthRepository {
  final ApiClient _client;

  AuthRepository(this._client);

  /// Logs in with an EXISTING account. There is no self-signup for drivers —
  /// POST /auth/signup always creates a 'passenger' (see backend/src/services
  /// /authService.js: registerUser never accepts a role). A driver account
  /// has to already exist with role='driver', set via a manual DB edit — see
  /// migration/README.md for the exact command.
  Future<DriverUser> login(String email, String password) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      final data = response.data ?? {};
      final accessToken = data['accessToken']?.toString();
      if (accessToken == null || accessToken.isEmpty) {
        throw AuthException('Login succeeded but no access token was returned.');
      }
      await _client.saveToken(accessToken);

      final user = DriverUser.fromJson(data['user'] as Map<String, dynamic>? ?? {});
      if (user.role != 'driver' && user.role != 'admin') {
        await _client.clearToken();
        throw AuthException(
          'This account has role "${user.role}", not "driver". '
          'See migration/README.md for how to promote it.',
        );
      }
      return user;
    } on DioException catch (error) {
      final message = error.response?.data is Map
          ? (error.response?.data['error']?.toString() ?? 'Login failed')
          : 'Login failed';
      throw AuthException(message);
    }
  }

  Future<DriverUser?> getCurrentUser() async {
    final token = await _client.getToken();
    if (token == null || token.isEmpty) return null;
    try {
      final response =
          await _client.dio.get<Map<String, dynamic>>(ApiEndpoints.me);
      final data = response.data ?? {};
      return DriverUser.fromJson(data['user'] as Map<String, dynamic>? ?? {});
    } on DioException {
      return null;
    }
  }

  Future<void> logout() => _client.clearToken();
}