import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/core/json_adapter.dart';

void main() {
  group('normalizeKeys', () {
    test('converts top-level snake_case keys to camelCase', () {
      expect(
        normalizeKeys({
          'booking_id': 'booking-1',
          'checkout_url': 'https://checkout.example',
          'status': 'pending',
        }),
        {
          'bookingId': 'booking-1',
          'checkoutUrl': 'https://checkout.example',
          'status': 'pending',
        },
      );
    });

    test('recursively converts nested maps and lists', () {
      final normalized = normalizeKeys({
        'payment': {
          'booking_id': {
            'trip_id': 'trip-1',
            'hold_expires_at': '2026-08-16T12:00:00.000Z',
          },
          'chapa_checkout_url': 'https://checkout.example',
        },
        'recent_locations': [
          {
            'trip_id': 'trip-1',
            'speed_kmh': 42.5,
            'recorded_at': '2026-08-16T12:01:00.000Z',
          },
        ],
      });

      expect(normalized['payment'], {
        'bookingId': {
          'tripId': 'trip-1',
          'holdExpiresAt': '2026-08-16T12:00:00.000Z',
        },
        'chapaCheckoutUrl': 'https://checkout.example',
      });
      expect(normalized['recentLocations'], [
        {
          'tripId': 'trip-1',
          'speedKmh': 42.5,
          'recordedAt': '2026-08-16T12:01:00.000Z',
        },
      ]);
    });
  });
}
