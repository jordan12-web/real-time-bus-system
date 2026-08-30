import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/config.dart';

class DriverApiException implements Exception {
  final String message;
  DriverApiException(this.message);
}

class DriverService {
  final ApiClient _client;
  DriverService(this._client);

  DriverApiException _mapError(DioException error) {
    final data = error.response?.data;
    final message = data is Map ? (data['error']?.toString() ?? 'Request failed') : 'Request failed';
    return DriverApiException(message);
  }

  /// POST /trips — role: driver or admin (see backend/src/routes/tripRoutes.js).
  /// route_id and vehicle_id are free-text strings on the real schema (no
  /// separate Route/Vehicle collections exist) — any non-empty string works.
  /// driver_id must be the CALLING driver's own user id (self-assignment);
  /// pass it explicitly rather than assuming the backend infers it.
  Future<Map<String, dynamic>> createTrip({
    required String routeId,
    required String vehicleId,
    required String driverId,
    required String origin,
    required String destination,
    required DateTime departureTime,
    required DateTime arrivalTime,
    required double pricePerSeat,
  }) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.trips,
        data: {
          'route_id': routeId,
          'vehicle_id': vehicleId,
          'driver_id': driverId,
          'origin': origin,
          'destination': destination,
          'departure_time': departureTime.toIso8601String(),
          'arrival_time': arrivalTime.toIso8601String(),
          'price_per_seat': pricePerSeat,
        },
      );
      return response.data ?? {};
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  /// GET /trips — public, unfiltered by driver (no driver-scoped listing
  /// endpoint exists on the backend). Caller filters client-side by
  /// driver_id == current user's id.
  Future<List<dynamic>> listAllTrips() async {
    try {
      final response = await _client.dio.get<List<dynamic>>(ApiEndpoints.trips);
      return response.data ?? [];
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  /// POST /tracking/report — role: driver or admin. Field casing verified
  /// against docs/api_key_format.md: tripId is camelCase, everything else
  /// in this body is snake_case — this is a deliberate, documented quirk of
  /// the real contract, not a typo.
  Future<void> reportLocation({
    required String tripId,
    required double latitude,
    required double longitude,
    double? speedKmh,
    double? heading,
  }) async {
    try {
      await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.trackingReport,
        data: {
          'tripId': tripId,
          'latitude': latitude,
          'longitude': longitude,
          if (speedKmh != null) 'speed_kmh': speedKmh,
          if (heading != null) 'heading': heading,
        },
      );
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  /// POST /tickets/validate — role: driver or admin.
  Future<Map<String, dynamic>> validateTicket(String qrCodeData) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.ticketValidate,
        data: {'qr_code_data': qrCodeData},
      );
      return response.data ?? {};
    } on DioException catch (error) {
      // A 400 here is a NORMAL "invalid ticket" response, not a transport
      // failure — the backend returns {valid:false, reason:...} with a 400
      // status. Surface that body instead of throwing generically.
      if (error.response?.statusCode == 400 && error.response?.data is Map) {
        return error.response!.data as Map<String, dynamic>;
      }
      throw _mapError(error);
    }
  }
}