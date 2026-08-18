import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/api/dio_client.dart';
import '../core/exceptions.dart';
import '../models/user.dart';
import '../services/auth_service.dart';


class AuthRepository {
  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';

  final AuthService _service;
  final FlutterSecureStorage _storage;

  AuthRepository(
    this._service, {
    FlutterSecureStorage? storage,
    DioClient? dioClient,
  }) : _storage = storage ?? const FlutterSecureStorage() {
    final client = dioClient;
    if (client != null) {
      client.onTokenRefresh = refresh;
    }
  }

  Future<User> signup({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    final response = await _service.signup(
      fullName: fullName,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
    );
    await _persistTokens(response);
    return User.fromJson(response['user'] as Map<String, dynamic>);
  }

  Future<User> login({required String email, required String password}) async {
    final response = await _service.login(email: email, password: password);
    await _persistTokens(response);
    return User.fromJson(response['user'] as Map<String, dynamic>);
  }

  Future<User> me() async {
    final response = await _service.me();
    return User.fromJson(response['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  
  Future<bool> refresh() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await logout();
      return false;
    }

    try {
      final response = await _service.refresh(refreshToken);
      await _persistTokens(response);
      return true;
    } on ApiException {
      await logout();
      return false;
    } catch (_) {
      await logout();
      return false;
    }
  }

  Future<void> _persistTokens(Map<String, dynamic> response) async {
    final accessToken = response['accessToken']?.toString();
    final refreshToken = response['refreshToken']?.toString();
    if (accessToken == null || refreshToken == null) {
      throw ApiException('Invalid auth response: missing tokens');
    }
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }
}
