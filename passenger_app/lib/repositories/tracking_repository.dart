import '../models/trip_location.dart';
import '../services/tracking_service.dart';

/// Thin wrapper around [TrackingService] for Passenger App.
class TrackingRepository {
  final TrackingService _service;

  TrackingRepository(this._service);

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
