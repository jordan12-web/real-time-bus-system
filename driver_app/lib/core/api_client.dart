import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'config.dart';


class ApiClient {
  final Dio dio;
  final FlutterSecureStorage _storage;

  ApiClient({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(),
        dio = Dio(BaseOptions(
          baseUrl: Config.apiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        )) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'driver_access_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<void> saveToken(String token) =>
      _storage.write(key: 'driver_access_token', value: token);

  Future<String?> getToken() => _storage.read(key: 'driver_access_token');

  Future<void> clearToken() => _storage.delete(key: 'driver_access_token');
}