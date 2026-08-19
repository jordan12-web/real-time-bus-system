import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/models/booking.dart';
import 'package:passenger_app/models/seat.dart';

void main() {
  group('Booking & Seat Model Unit Tests', () {
    test('Seat.fromJson parses label and availability', () {
      final json = {'id': 's1', 'label': 'Seat 5', 'is_available': true};
      final seat = Seat.fromJson(json);
      expect(seat.id, equals('s1'));
      expect(seat.label, equals('Seat 5'));
      expect(seat.isAvailable, isTrue);
    });

    test('Booking.fromJson parses seatNumber correctly', () {
      final json = {
        'id': 'booking_1',
        'user_id': 'user_1',
        'trip_id': 'trip_1',
        'seat_number': 'Seat 12',
        'status': 'pending',
        'total_amount': 350.0,
        'currency': 'ETB',
      };

      final booking = Booking.fromJson(json);

      expect(booking.id, equals('booking_1'));
      expect(booking.seatNumber, equals('Seat 12'));
      expect(booking.status, equals('pending'));
    });
  });
}
