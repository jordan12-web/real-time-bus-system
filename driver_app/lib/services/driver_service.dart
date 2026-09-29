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

  
  
  
  Future<List<dynamic>> listAllTrips() async {
    try {
      final response = await _client.dio.get<List<dynamic>>(ApiEndpoints.trips);
      return response.data ?? [];
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  
  
  
  
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
          'speed_kmh': ?speedKmh,
          'heading': ?heading,
        },
      );
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  
  Future<Map<String, dynamic>> validateTicket(String qrCodeData) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.ticketValidate,
        data: {'qr_code_data': qrCodeData},
      );
      return response.data ?? {};
    } on DioException catch (error) {
      
      
      
      if (error.response?.statusCode == 400 && error.response?.data is Map) {
        return error.response!.data as Map<String, dynamic>;
      }
      throw _mapError(error);
    }
  }
}
