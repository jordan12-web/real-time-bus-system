import '../core/exceptions.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../services/trip_service.dart';

/// Booking operations with basic trip availability checks.
class BookingRepository {
  final BookingService _bookingService;
  final TripService _tripService;

  BookingRepository(this._bookingService, this._tripService);

  Future<Booking> createBooking(String tripId) async {
    final trip = await _tripService.getTrip(tripId);
    if (trip['status']?.toString() != 'scheduled') {
      throw ApiException('Trip is not available for booking');
    }

    try {
      final raw = await _bookingService.createBooking(tripId);
      final booking = Booking.fromJson(raw);
      if (booking.tripId != tripId) {
        throw ApiException('Booking trip mismatch — possible double-booking');
      }
      return booking;
    } on ApiException catch (error) {
      if (error.statusCode == 400) {
        throw ApiException(
          'Unable to create booking: ${error.message}. '
          'You may already have an active booking for this trip.',
          statusCode: error.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<Booking> getBooking(String id) async {
    final raw = await _bookingService.getBooking(id);
    return Booking.fromJson(raw);
  }

  Future<Booking> cancelBooking(String id) async {
    final raw = await _bookingService.cancelBooking(id);
    return Booking.fromJson(raw);
  }
}
