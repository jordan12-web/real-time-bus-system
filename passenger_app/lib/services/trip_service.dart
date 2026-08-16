import 'package:dio/dio.dart';

import '../core/api/dio_client.dart';
import '../core/json_adapter.dart';

/// Trip API client — mirrors OpenAPI `/trips` paths.
class TripService {
  final DioClient _client;

  TripService(this._client);

  Future<List<dynamic>> listTrips() async {
    try {
      final response = await _client.sendWithRetry(
        () => _client.dio.get<List<dynamic>>('/trips'),
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
