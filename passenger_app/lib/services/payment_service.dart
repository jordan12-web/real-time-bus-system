import 'package:dio/dio.dart';

import '../core/api/dio_client.dart';
import '../core/json_adapter.dart';

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
          // This endpoint is the camelCase exception in the backend contract.
          data: {'bookingId': bookingId, 'returnUrl': ?returnUrl},
        ),
      );
      return normalizeKeys(response.data ?? {});
    } on DioException catch (error) {
      throw _client.handleDioError(error);
    }
  }

  Future<Map<String, dynamic>> getPayment(String id) async {
    try {
      final response = await _client.sendWithRetry(
        () => _client.dio.get<Map<String, dynamic>>('/payments/$id'),
      );
      return normalizeKeys(response.data ?? {});
    } on DioException catch (error) {
      throw _client.handleDioError(error);
    }
  }
}
