import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:passenger_app/controllers/trip_controller.dart';
import 'package:passenger_app/models/trip.dart';
import 'package:passenger_app/repositories/trip_repository.dart';

class MockTripRepository extends Mock implements TripRepository {}

void main() {
  group('TripController Search Unit Tests', () {
    late MockTripRepository mockRepository;
    late TripController controller;

    setUp(() {
      mockRepository = MockTripRepository();
      controller = TripController(mockRepository);
    });

    test('searchTrips updates state with filtered trips', () async {
      final dummyTrips = [
        Trip(
          id: 't1',
          routeId: 'r1',
          origin: 'Addis Ababa',
          destination: 'Hawassa',
          vehicleId: 'v1',
          driverId: 'd1',
          departureTime: DateTime.now(),
          arrivalTime: DateTime.now().add(const Duration(hours: 5)),
          pricePerSeat: 350,
          status: 'scheduled',
        ),
      ];

      when(() => mockRepository.searchTrips(origin: 'Addis Ababa', destination: 'Hawassa'))
          .thenAnswer((_) async => dummyTrips);

      await controller.searchTrips(origin: 'Addis Ababa', destination: 'Hawassa');

      expect(controller.state.trips.length, equals(1));
      expect(controller.state.trips.first.origin, equals('Addis Ababa'));
      expect(controller.state.trips.first.destination, equals('Hawassa'));
    });
  });
}
