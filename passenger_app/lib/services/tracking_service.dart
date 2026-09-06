import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../core/api/dio_client.dart';
import '../core/config.dart';
import '../core/exceptions.dart';
import '../core/json_adapter.dart';
import '../models/trip_location.dart';

class TrackingService {
  final DioClient _client;
  final Future<String?> Function()? _accessTokenProvider;

  TrackingService(
    this._client, {
    Future<String?> Function()? accessTokenProvider,
  }) : _accessTokenProvider = accessTokenProvider;

  

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
          .map(
            (item) => TripLocation.fromJson(
              normalizeKeys(item as Map<String, dynamic>),
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw _client.handleDioError(error);
    }
  }

  Stream<TripLocation> subscribeSse(String tripId) async* {
    final provider = _accessTokenProvider;
    final token = provider != null ? await provider() : null;
    if (token == null || token.isEmpty) {
      throw ApiException('Unauthorized', statusCode: 401);
    }

    final url = '${Config.sseUrl}/tracking/$tripId/stream';


    final sseDio = Dio(
      BaseOptions(
        responseType: ResponseType.stream,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'text/event-stream',
          'Cache-Control': 'no-cache',
        },

        receiveTimeout: Duration.zero,
      ),
    );

    late Response<ResponseBody> response;
    try {
      response = await sseDio.get<ResponseBody>(url);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'SSE connection failed',
        statusCode: e.response?.statusCode,
      );
    }

    final stream = response.data!.stream;
    final buffer = StringBuffer();

    await for (final chunk in stream) {
      
      buffer.write(utf8.decode(chunk));

      
      final raw = buffer.toString();
      final lines = raw.split('\n');

      
      buffer
        ..clear()
        ..write(lines.last);

      for (final line in lines.sublist(0, lines.length - 1)) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith(':')) continue; // SSE comment

        
        final jsonStr = trimmed.startsWith('data:')
            ? trimmed.substring(5).trimLeft()
            : trimmed;

        if (jsonStr.isEmpty) continue;

        try {
          final decoded = jsonDecode(jsonStr);
          if (decoded is Map<String, dynamic> &&
              decoded.containsKey('latitude') &&
              decoded.containsKey('longitude')) {
            yield TripLocation.fromJson(normalizeKeys(decoded));
          }
        } catch (_) {
          // Malformed JSON in one frame — skip and continue streaming
        }
      }
    }
  }
}
