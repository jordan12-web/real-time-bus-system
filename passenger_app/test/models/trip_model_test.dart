import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/models/trip.dart';

void main() {
  group('Trip Model Unit Tests', () {
    test('Trip.fromJson parses origin and destination correctly', () {
      final json = {
        'id': 'trip_101',
        'route_id': 'ROUTE_01',
        'origin': 'Addis Ababa',
        'destination': 'Hawassa',
        'vehicle_id': 'BUS_01',
        'driver_id': 'driver_01',
        'departure_time': '2026-08-20T08:00:00.000Z',
        'arrival_time': '2026-08-20T13:00:00.000Z',
        'price_per_seat': 350.0,
        'status': 'scheduled',
      };

      final trip = Trip.fromJson(json);

      expect(trip.id, equals('trip_101'));
      expect(trip.origin, equals('Addis Ababa'));
      expect(trip.destination, equals('Hawassa'));
      expect(trip.pricePerSeat, equals(350.0));
      expect(trip.status, equals('scheduled'));
    });

    test('Trip.toJson includes origin and destination', () {
      final trip = Trip(
        id: 'trip_102',
        routeId: 'ROUTE_02',
        origin: 'Hawassa',
        destination: 'Addis Ababa',
        vehicleId: 'BUS_02',
        driverId: 'driver_02',
        departureTime: DateTime.parse('2026-08-21T09:00:00.000Z'),
        arrivalTime: DateTime.parse('2026-08-21T14:00:00.000Z'),
        pricePerSeat: 400.0,
        status: 'scheduled',
      );

      final json = trip.toJson();

      expect(json['origin'], equals('Hawassa'));
      expect(json['destination'], equals('Addis Ababa'));
      expect(json['price_per_seat'], equals(400.0));
    });
  });
}
