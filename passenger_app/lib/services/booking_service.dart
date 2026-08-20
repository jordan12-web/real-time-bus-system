import 'package:dio/dio.dart';

import '../core/api/dio_client.dart';
import '../core/json_adapter.dart';

/// Booking API client — mirrors OpenAPI `/bookings` paths.
class BookingService {
  final DioClient _client;

  BookingService(this._client);

  Future<Map<String, dynamic>> createBooking(String tripId, {String? seatNumber}) async {
    try {
      final data = <String, dynamic>{'trip_id': tripId};
      if (seatNumber != null && seatNumber.isNotEmpty) {
        data['seat_number'] = seatNumber;
      }

      final response = await _client.sendWithRetry(
        () => _client.dio.post<Map<String, dynamic>>(
          '/bookings',
          data: data,
        ),
      );
      return normalizeKeys(response.data ?? {});
    } on DioException catch (error) {
      throw _client.handleDioError(error);
    }
  }

  Future<Map<String, dynamic>> getBooking(String id) async {
    try {
      final response = await _client.sendWithRetry(
        () => _client.dio.get<Map<String, dynamic>>('/bookings/$id'),
      );
      return normalizeKeys(response.data ?? {});
    } on DioException catch (error) {
      throw _client.handleDioError(error);
    }
  }

  Future<Map<String, dynamic>> cancelBooking(String id) async {
    try {
      final response = await _client.sendWithRetry(
        () => _client.dio.delete<Map<String, dynamic>>('/bookings/$id'),
      );
      return normalizeKeys(response.data ?? {});
    } on DioException catch (error) {
      throw _client.handleDioError(error);
    }
  }

  Future<List<dynamic>> listMyBookings() async {
    try {
      final response = await _client.sendWithRetry(
        () => _client.dio.get<List<dynamic>>('/bookings'),
      );
      return response.data ?? [];
    } on DioException catch (error) {
      throw _client.handleDioError(error);
    }
  }
}