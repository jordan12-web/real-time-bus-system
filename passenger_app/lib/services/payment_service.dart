import 'package:dio/dio.dart';

import '../core/api/dio_client.dart';

/// Payment API client — mirrors OpenAPI `/payments/*` paths.
class PaymentService {
  final DioClient _client;

  PaymentService(this._client);

  Future<Map<String, dynamic>> initiatePayment({
    required String bookingId,
    String? returnUrl,
  }) async {
    try {
      final response = await _client.sendWithRetry(
        () => _client.dio.post<Map<String, dynamic>>(
          '/payments/initiate',
          data: {
            'bookingId': bookingId,
            'return_url': ?returnUrl,
          },
        ),
      );
      return response.data ?? {};
    } on DioException catch (error) {
      throw _client.handleDioError(error);
    }
  }

  Future<Map<String, dynamic>> getPayment(String id) async {
    try {
      final response = await _client.sendWithRetry(
        () => _client.dio.get<Map<String, dynamic>>('/payments/$id'),
      );
      return response.data ?? {};
    } on DioException catch (error) {
      throw _client.handleDioError(error);
    }
  }
}
