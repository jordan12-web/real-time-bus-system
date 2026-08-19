import 'package:dio/dio.dart';

import '../core/api/dio_client.dart';
import '../core/json_adapter.dart';

class TicketService {
  final DioClient _client;

  TicketService(this._client);

  Future<Map<String, dynamic>> generateTicket(String bookingId) async {
    try {
      final response = await _client.sendWithRetry(
        () => _client.dio.post<Map<String, dynamic>>(
          '/tickets/$bookingId/generate',
        ),
      );
      return normalizeKeys(response.data ?? {});
    } on DioException catch (error) {
      throw _client.handleDioError(error);
    }
  }
}
