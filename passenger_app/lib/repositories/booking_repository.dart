import '../core/exceptions.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../services/trip_service.dart';

/// Booking operations with basic trip availability checks and seat allocation handling.
class BookingRepository {
  final BookingService _bookingService;
  final TripService _tripService;
  final Set<String> _pendingSeats = {};

  BookingRepository(this._bookingService, this._tripService);

  Future<Booking> createBooking(String tripId, {String? seatNumber}) async {
    final trip = await _tripService.getTrip(tripId);
    if (trip['status']?.toString() != 'scheduled') {
      throw ApiException('Trip is not available for booking');
    }

    final seatKey = '$tripId-${seatNumber ?? "default"}';
    if (seatNumber != null && _pendingSeats.contains(seatKey)) {
      throw ApiException('Seat $seatNumber is currently reserved in another pending booking flow');
    }

    _pendingSeats.add(seatKey);

    try {
      final raw = await _bookingService.createBooking(tripId, seatNumber: seatNumber);
      final booking = Booking.fromJson(raw);
      if (booking.tripId != tripId) {
        throw ApiException('Booking trip mismatch — possible double-booking');
      }
      return booking;
    } on ApiException catch (error) {
      _pendingSeats.remove(seatKey);
      if (error.statusCode == 400) {
        throw ApiException(
          'Unable to create booking: ${error.message}. '
          'You may already have an active booking or the selected seat is unavailable.',
          statusCode: error.statusCode,
        );
      }
      rethrow;
    } catch (e) {
      _pendingSeats.remove(seatKey);
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
