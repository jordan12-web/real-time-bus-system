import '../models/trip.dart';
import '../models/ticket_validation_result.dart';
import '../services/driver_service.dart';

class DriverTripRepository {
  final DriverService _service;
  DriverTripRepository(this._service);

  Future<Trip> createTrip({
    required String routeId,
    required String vehicleId,
    required String driverId,
    required String origin,
    required String destination,
    required DateTime departureTime,
    required DateTime arrivalTime,
    required double pricePerSeat,
  }) async {
    final raw = await _service.createTrip(
      routeId: routeId,
      vehicleId: vehicleId,
      driverId: driverId,
      origin: origin,
      destination: destination,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      pricePerSeat: pricePerSeat,
    );
    return Trip.fromJson(raw);
  }

  /// Lists trips assigned to [driverId]. Filters client-side since the
  /// backend has no driver-scoped trip listing endpoint (GET /trips is
  /// public and unfiltered by driver).
  Future<List<Trip>> listMyTrips(String driverId) async {
    final rawList = await _service.listAllTrips();
    return rawList
        .map((item) => Trip.fromJson(item as Map<String, dynamic>))
        .where((trip) => trip.driverId == driverId)
        .toList();
  }

  Future<void> reportLocation({
    required String tripId,
    required double latitude,
    required double longitude,
    double? speedKmh,
    double? heading,
  }) {
    return _service.reportLocation(
      tripId: tripId,
      latitude: latitude,
      longitude: longitude,
      speedKmh: speedKmh,
      heading: heading,
    );
  }

  Future<TicketValidationResult> validateTicket(String qrCodeData) async {
    final raw = await _service.validateTicket(qrCodeData);
    return TicketValidationResult.fromJson(raw);
  }
}