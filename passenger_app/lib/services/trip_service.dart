import 'package:dio/dio.dart';

import '../core/api/dio_client.dart';
import '../core/json_adapter.dart';

/// Trip API client — mirrors OpenAPI `/trips` paths with search support.
class TripService {
  final DioClient _client;

  TripService(this._client);

  Future<List<dynamic>> listTrips({
    String? origin,
    String? destination,
    DateTime? time,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (origin != null && origin.isNotEmpty) queryParams['origin'] = origin;
      if (destination != null && destination.isNotEmpty) queryParams['destination'] = destination;
      if (time != null) queryParams['time'] = time.toIso8601String();

      final response = await _client.sendWithRetry(
        () => _client.dio.get<List<dynamic>>(
          '/trips',
          queryParameters: queryParams.isNotEmpty ? queryParams : null,
        ),
      );
      return normalizeJsonList(response.data ?? []);
    } on DioException catch (error) {
      throw _client.handleDioError(error);
    }
  }

  Future<Map<String, dynamic>> getTrip(String id) async {
    try {
      final response = await _client.sendWithRetry(
        () => _client.dio.get<Map<String, dynamic>>('/trips/$id'),
      );
      return normalizeKeys(response.data ?? {});
    } on DioException catch (error) {
      throw _client.handleDioError(error);
    }
  }
}
