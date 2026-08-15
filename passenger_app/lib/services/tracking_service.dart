import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eventsource/eventsource.dart';

import '../core/api/dio_client.dart';
import '../core/config.dart';
import '../core/exceptions.dart';
import '../models/trip_location.dart';

/// Tracking API client — mirrors OpenAPI `/tracking/*` paths.
class TrackingService {
  final DioClient _client;
  final Future<String?> Function()? _accessTokenProvider;

  TrackingService(
    this._client, {
    Future<String?> Function()? accessTokenProvider,
  }) : _accessTokenProvider = accessTokenProvider;

  Future<TripLocation> reportLocation({
    required String tripId,
    required double latitude,
    required double longitude,
    double? speedKmh,
    double? heading,
  }) async {
    try {
      final response = await _client.sendWithRetry(
        () => _client.dio.post<Map<String, dynamic>>(
          '/tracking/report',
          data: {
            'tripId': tripId,
            'latitude': latitude,
            'longitude': longitude,
            'speed_kmh': ?speedKmh,
            'heading': ?heading,
          },
        ),
      );
      return TripLocation.fromJson(response.data ?? {});
    } on DioException catch (error) {
      throw _client.handleDioError(error);
    }
  }

  Future<List<TripLocation>> getRecentLocations(
    String tripId, {
    int limit = 50,
  }) async {
    try {
      final response = await _client.sendWithRetry(
        () => _client.dio.get<List<dynamic>>(
          '/tracking/$tripId/recent',
          queryParameters: {'limit': limit},
        ),
      );
      final rawList = response.data ?? [];
      return rawList
          .map((item) => TripLocation.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw _client.handleDioError(error);
    }
  }

  /// Subscribes to `GET /tracking/{tripId}/stream` SSE updates.
  Stream<TripLocation> subscribeSse(String tripId) async* {
    final provider = _accessTokenProvider;
    final token = provider != null ? await provider() : null;
    if (token == null || token.isEmpty) {
      throw ApiException('Unauthorized', statusCode: 401);
    }

    final url = '${Config.sseUrl}/tracking/$tripId/stream';
    final eventSource = await EventSource.connect(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    await for (final event in eventSource) {
      final data = event.data;
      if (data == null || data.isEmpty) continue;

      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('latitude') &&
            decoded.containsKey('longitude')) {
          yield TripLocation.fromJson(decoded);
        }
      }
    }
  }
}
