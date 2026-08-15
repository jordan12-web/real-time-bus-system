import 'package:dio/dio.dart';

import '../core/api/dio_client.dart';

/// Booking API client — mirrors OpenAPI `/bookings` paths.
class BookingService {
  final DioClient _client;

  BookingService(this._client);

  Future<Map<String, dynamic>> createBooking(String tripId) async {
    try {
      final response = await _client.sendWithRetry(
        () => _client.dio.post<Map<String, dynamic>>(
          '/bookings',
          data: {'trip_id': tripId},
        ),
      );
      return response.data ?? {};
    } on DioException catch (error) {
      throw _client.handleDioError(error);
    }
  }

  Future<Map<String, dynamic>> getBooking(String id) async {
    try {
      final response = await _client.sendWithRetry(
        () => _client.dio.get<Map<String, dynamic>>('/bookings/$id'),
      );
      return response.data ?? {};
    } on DioException catch (error) {
      throw _client.handleDioError(error);
    }
  }

  Future<Map<String, dynamic>> cancelBooking(String id) async {
    try {
      final response = await _client.sendWithRetry(
        () => _client.dio.delete<Map<String, dynamic>>('/bookings/$id'),
      );
      return response.data ?? {};
    } on DioException catch (error) {
      throw _client.handleDioError(error);
    }
  }
}
