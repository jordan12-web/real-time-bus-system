import '../models/trip.dart';
import '../services/trip_service.dart';

/// Trip list/detail access with search support and in-memory caching.
class TripRepository {
  final TripService _service;
  List<Trip>? _cachedTrips;

  TripRepository(this._service);

  Future<List<Trip>> listTrips({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedTrips != null) {
      return _cachedTrips!;
    }

    final rawList = await _service.listTrips();
    _cachedTrips = rawList
        .map((item) => Trip.fromJson(item as Map<String, dynamic>))
        .toList();
    return _cachedTrips!;
  }

  Future<List<Trip>> searchTrips({
    String? origin,
    String? destination,
    DateTime? time,
  }) async {
    final rawList = await _service.listTrips(
      origin: origin,
      destination: destination,
      time: time,
    );
    final trips = rawList
        .map((item) => Trip.fromJson(item as Map<String, dynamic>))
        .toList();
    
    // Client-side fallback filter if backend does not yet filter by origin/destination
    return trips.where((trip) {
      if (origin != null && origin.isNotEmpty) {
        if (!trip.origin.toLowerCase().contains(origin.toLowerCase())) return false;
      }
      if (destination != null && destination.isNotEmpty) {
        if (!trip.destination.toLowerCase().contains(destination.toLowerCase())) return false;
      }
      return true;
    }).toList();
  }

  Future<Trip> getTrip(String id) async {
    final raw = await _service.getTrip(id);
    return Trip.fromJson(raw);
  }

  void clearCache() => _cachedTrips = null;
}
