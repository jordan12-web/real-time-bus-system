import 'package:dio/dio.dart';

import '../config.dart';
import '../exceptions.dart';
import '../../utils/retry.dart';

typedef TokenRefreshCallback = Future<bool> Function();
typedef AccessTokenProvider = Future<String?> Function();

/// Shared Dio client with auth, retry, and error mapping.
class DioClient {
  late final Dio _dio;
  AccessTokenProvider? getAccessToken;
  TokenRefreshCallback? onTokenRefresh;
  bool _isRefreshing = false;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Config.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: const {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = getAccessToken != null ? await getAccessToken!() : null;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          if (statusCode == 401 && onTokenRefresh != null && !_isRefreshing) {
            _isRefreshing = true;
            try {
              final refreshed = await onTokenRefresh!();
              if (refreshed) {
                final opts = error.requestOptions;
                final token = getAccessToken != null
                    ? await getAccessToken!()
                    : null;
                if (token != null && token.isNotEmpty) {
                  opts.headers['Authorization'] = 'Bearer $token';
                }
                final response = await _dio.request<dynamic>(
                  opts.path,
                  data: opts.data,
                  queryParameters: opts.queryParameters,
                  options: Options(
                    method: opts.method,
                    headers: opts.headers,
                    extra: opts.extra,
                    responseType: opts.responseType,
                    contentType: opts.contentType,
                  ),
                );
                return handler.resolve(response);
              }
              return handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  response: error.response,
                  type: DioExceptionType.badResponse,
                  error: ApiException('Unauthorized', statusCode: 401),
                ),
              );
            } catch (_) {
              return handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  response: error.response,
                  type: DioExceptionType.badResponse,
                  error: ApiException('Unauthorized', statusCode: 401),
                ),
              );
            } finally {
              _isRefreshing = false;
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response<T>> sendWithRetry<T>(
    Future<Response<T>> Function() request, {
    int maxAttempts = 3,
  }) {
    return retryWithBackoff<Response<T>>(
      maxAttempts: maxAttempts,
      action: request,
      shouldRetry: (attempt, error) {
        if (error is DioException) {
          return error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError;
        }
        return false;
      },
    );
  }

  ApiException handleDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    if (error.error is ApiException) {
      return error.error as ApiException;
    }

    var message = 'An unexpected error occurred';
    final data = error.response?.data;
    if (data is Map && data['error'] is String) {
      message = data['error'] as String;
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      message = 'Connection timed out. Please check your network connection.';
    } else if (error.type == DioExceptionType.connectionError) {
      message =
          'Unable to connect to server. Please ensure backend is running.';
    }

    return ApiException(message, statusCode: statusCode);
  }
}
