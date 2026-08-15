import '../models/trip_location.dart';
import '../services/tracking_service.dart';

/// Thin wrapper around [TrackingService].
class TrackingRepository {
  final TrackingService _service;

  TrackingRepository(this._service);

  Future<TripLocation> reportLocation({
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

  Future<List<TripLocation>> getRecentLocations(
    String tripId, {
    int limit = 50,
  }) {
    return _service.getRecentLocations(tripId, limit: limit);
  }

  Stream<TripLocation> subscribeSse(String tripId) {
    return _service.subscribeSse(tripId);
  }
}
