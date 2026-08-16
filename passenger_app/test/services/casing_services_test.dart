import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/core/api/dio_client.dart';
import 'package:passenger_app/services/booking_service.dart';
import 'package:passenger_app/services/payment_service.dart';
import 'package:passenger_app/services/tracking_service.dart';
import 'package:passenger_app/services/trip_service.dart';

class RecordedRequest {
  final String method;
  final String path;
  final dynamic data;
  final Map<String, dynamic> queryParameters;

  const RecordedRequest({
    required this.method,
    required this.path,
    required this.data,
    required this.queryParameters,
  });
}

class FakeHttpClientAdapter implements HttpClientAdapter {
  final dynamic Function(RequestOptions options) handler;
  final requests = <RecordedRequest>[];

  FakeHttpClientAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(
      RecordedRequest(
        method: options.method,
        path: options.path,
        data: options.data,
        queryParameters: options.queryParameters,
      ),
    );

    return ResponseBody.fromString(
      jsonEncode(handler(options)),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

DioClient clientWith(FakeHttpClientAdapter adapter) {
  final client = DioClient();
  client.dio.httpClientAdapter = adapter;
  return client;
}

void main() {
  group('BookingService casing', () {
    test(
      'createBooking sends trip_id and returns normalized response',
      () async {
        final adapter = FakeHttpClientAdapter((_) {
          return {
            'id': 'booking-1',
            'trip_id': 'trip-1',
            'user_id': 'user-1',
            'total_amount': 350,
            'hold_expires_at': '2026-08-16T12:00:00.000Z',
          };
        });
        final service = BookingService(clientWith(adapter));

        final result = await service.createBooking('trip-1');

        expect(adapter.requests.single.method, 'POST');
        expect(adapter.requests.single.path, '/bookings');
        expect(adapter.requests.single.data, {'trip_id': 'trip-1'});
        expect(result['tripId'], 'trip-1');
        expect(result['userId'], 'user-1');
        expect(result['totalAmount'], 350);
        expect(result['holdExpiresAt'], '2026-08-16T12:00:00.000Z');
      },
    );

    test('getBooking normalizes snake_case response keys', () async {
      final adapter = FakeHttpClientAdapter((_) {
        return {'id': 'booking-1', 'trip_id': 'trip-1', 'user_id': 'user-1'};
      });
      final service = BookingService(clientWith(adapter));

      final result = await service.getBooking('booking-1');

      expect(result['tripId'], 'trip-1');
      expect(result['userId'], 'user-1');
    });
  });

  group('PaymentService casing', () {
    test('initiatePayment sends bookingId and returnUrl', () async {
      final adapter = FakeHttpClientAdapter((_) {
        return {
          'checkout_url': 'https://checkout.example',
          'payment': {
            'id': 'payment-1',
            'booking_id': 'booking-1',
            'chapa_tx_ref': 'tx-1',
            'chapa_checkout_url': 'https://checkout.example',
          },
        };
      });
      final service = PaymentService(clientWith(adapter));

      final result = await service.initiatePayment(
        bookingId: 'booking-1',
        returnUrl: 'app://payments/success',
      );

      expect(adapter.requests.single.method, 'POST');
      expect(adapter.requests.single.path, '/payments/initiate');
      expect(adapter.requests.single.data, {
        'bookingId': 'booking-1',
        'returnUrl': 'app://payments/success',
      });
      expect(result['checkoutUrl'], 'https://checkout.example');
      expect(result['payment']['bookingId'], 'booking-1');
      expect(result['payment']['chapaTxRef'], 'tx-1');
      expect(result['payment']['chapaCheckoutUrl'], 'https://checkout.example');
    });

    test('getPayment normalizes wrapper and nested payment keys', () async {
      final adapter = FakeHttpClientAdapter((_) {
        return {
          'payment': {
            'id': 'payment-1',
            'booking_id': 'booking-1',
            'chapa_tx_ref': 'tx-1',
          },
        };
      });
      final service = PaymentService(clientWith(adapter));

      final result = await service.getPayment('payment-1');

      expect(result['payment']['bookingId'], 'booking-1');
      expect(result['payment']['chapaTxRef'], 'tx-1');
    });
  });

  group('Representative GET/list response normalization', () {
    test('TripService normalizes list and detail responses', () async {
      final adapter = FakeHttpClientAdapter((options) {
        if (options.path == '/trips') {
          return [
            {'id': 'trip-1', 'route_id': 'route-1', 'price_per_seat': 350},
          ];
        }
        return {'id': 'trip-1', 'route_id': 'route-1', 'price_per_seat': 350};
      });
      final service = TripService(clientWith(adapter));

      final trips = await service.listTrips();
      final trip = await service.getTrip('trip-1');

      expect((trips.single as Map<String, dynamic>)['routeId'], 'route-1');
      expect((trips.single as Map<String, dynamic>)['pricePerSeat'], 350);
      expect(trip['routeId'], 'route-1');
      expect(trip['pricePerSeat'], 350);
    });

    test('TrackingService normalizes recent location responses', () async {
      final adapter = FakeHttpClientAdapter((_) {
        return [
          {
            'id': 'location-1',
            'trip_id': 'trip-1',
            'latitude': 9.0222,
            'longitude': 38.7468,
            'speed_kmh': 65,
            'recorded_at': '2026-08-16T12:00:00.000Z',
          },
        ];
      });
      final service = TrackingService(clientWith(adapter));

      final locations = await service.getRecentLocations('trip-1');

      expect(locations.single.tripId, 'trip-1');
      expect(locations.single.speedKmh, 65);
      expect(locations.single.recordedAt, '2026-08-16T12:00:00.000Z');
    });
  });
}
