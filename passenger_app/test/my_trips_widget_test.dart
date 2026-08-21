import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:passenger_app/controllers/auth_controller.dart';
import 'package:passenger_app/models/booking.dart';
import 'package:passenger_app/models/trip.dart';
import 'package:passenger_app/repositories/booking_repository.dart';
import 'package:passenger_app/repositories/trip_repository.dart';
import 'package:passenger_app/screens/my_trips_screen.dart';
import 'package:passenger_app/theme/theme_provider.dart';

class _MockBookingRepository extends Mock implements BookingRepository {}

class _MockTripRepository extends Mock implements TripRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThemeProvider themeProvider;
  late _MockBookingRepository bookingRepository;
  late _MockTripRepository tripRepository;

  final sampleBooking = Booking(
    id: 'booking-1',
    userId: 'user-1',
    tripId: 'trip-1',
    seatNumber: 'A1',
    status: 'confirmed',
    totalAmount: 350,
    currency: 'ETB',
  );

  final sampleTrip = Trip(
    id: 'trip-1',
    routeId: 'route-1',
    origin: 'Addis Ababa',
    destination: 'Hawassa',
    vehicleId: 'v1',
    driverId: 'd1',
    departureTime: DateTime(2026, 8, 21, 8, 30),
    arrivalTime: DateTime(2026, 8, 21, 14, 0),
    pricePerSeat: 350,
    status: 'scheduled',
  );

  setUp(() {
    themeProvider = ThemeProvider.forTesting();
    bookingRepository = _MockBookingRepository();
    tripRepository = _MockTripRepository();

    when(() => bookingRepository.listMyBookings())
        .thenAnswer((_) async => [sampleBooking]);
    when(() => tripRepository.getTrip('trip-1'))
        .thenAnswer((_) async => sampleTrip);
  });

  testWidgets('My Trips renders origin, destination, departure, and status', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themeProviderInstance.overrideWith((ref) => themeProvider),
          bookingRepositoryProvider.overrideWith((ref) => bookingRepository),
          tripRepositoryProvider.overrideWith((ref) => tripRepository),
        ],
        child: MaterialApp(home: const MyTripsScreen()),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('my_trips_list')), findsOneWidget);
    expect(find.textContaining('Addis Ababa'), findsOneWidget);
    expect(find.textContaining('Hawassa'), findsOneWidget);
    expect(find.textContaining('Aug 21'), findsOneWidget);
    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.textContaining('ETA'), findsOneWidget);
  });
}
