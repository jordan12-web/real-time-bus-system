import 'package:dio/dio.dart';

import '../core/api/dio_client.dart';

/// Service responsible for communicating with the backend Smart Passenger Assistant endpoint.
class AiService {
  final DioClient _client;

  AiService(this._client);

  Future<Map<String, dynamic>> queryAssistant(String question) async {
    try {
      final response = await _client.sendWithRetry(
        () => _client.dio.post<Map<String, dynamic>>(
          '/ai/query',
          data: {'question': question},
        ),
        // Timeouts here are usually a slow model, not a dropped packet.
        // Retrying would wait another 30s+ without improving answers.
        maxAttempts: 1,
      );

      final body = response.data;
      if (body != null && body['data'] is Map<String, dynamic>) {
        return body['data'] as Map<String, dynamic>;
      }

      return {
        'answer': body?['answer']?.toString() ?? 'I received your query but could not extract an answer.',
        'confidence': 0.8,
        'actionType': 'none',
      };
    } on DioException catch (error) {
      throw _client.handleDioError(error);
    }
  }
}
