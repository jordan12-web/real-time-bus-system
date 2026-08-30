import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:driver_app/controllers/driver_trip_controller.dart';
import 'package:driver_app/repositories/driver_trip_repository.dart';
import 'package:driver_app/services/driver_service.dart';

class MockDriverService extends Mock implements DriverService {}

void main() {
  group('DriverTripController.createTrip', () {
    late MockDriverService mockService;
    late DriverTripRepository repository;
    late DriverTripController controller;

    setUp(() {
      mockService = MockDriverService();
      repository = DriverTripRepository(mockService);
      controller = DriverTripController(repository);
    });

    test('TODO: stub mockService.createTrip and assert state.lastCreatedTrip is set', () async {
      // TODO: when(() => mockService.createTrip(...)).thenAnswer((_) async => {...});
      // then call controller.createTrip(...) and assert controller.state.lastCreatedTrip
      // matches, and state.trips contains it.
      expect(controller.state.trips, isEmpty);
    });

    test('TODO: on DriverApiException, assert state.errorMessage is set and isLoading is false', () async {
      // TODO: when(() => mockService.createTrip(...)).thenThrow(DriverApiException('...'));
      expect(controller.state.errorMessage, isNull);
    });
  });

  group('DriverTripController.validateTicket', () {
    late MockDriverService mockService;
    late DriverTripRepository repository;
    late DriverTripController controller;

    setUp(() {
      mockService = MockDriverService();
      repository = DriverTripRepository(mockService);
      controller = DriverTripController(repository);
    });

    test('TODO: stub a valid-ticket response and assert state.lastValidation.valid is true', () async {
      // TODO: when(() => mockService.validateTicket(any()))
      //     .thenAnswer((_) async => {'valid': true, 'ticket': {'booking_id': 'b1'}});
      expect(controller.state.lastValidation, isNull);
    });

    test('TODO: stub an already-used ticket response and assert reason is surfaced', () async {
      // TODO: when(() => mockService.validateTicket(any())).thenAnswer((_) async =>
      //     {'valid': false, 'reason': 'Ticket has already been used', 'ticket': {...}});
      expect(controller.state.lastValidation, isNull);
    });
  });
}