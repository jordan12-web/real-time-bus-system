/// GPS location point for a trip.
///
/// OpenAPI defines request fields on `POST /tracking/report` but no response
/// schema for `GET /tracking/{tripId}/recent` — `id` and `recorded_at` are
/// mapped from backend payloads.
class TripLocation {
  final String id;
  final String tripId;
  final double latitude;
  final double longitude;
  final double speedKmh;
  final double heading;
  final String? recordedAt;

  const TripLocation({
    required this.id,
    required this.tripId,
    required this.latitude,
    required this.longitude,
    required this.speedKmh,
    required this.heading,
    this.recordedAt,
  });

  factory TripLocation.fromJson(Map<String, dynamic> json) {
    return TripLocation(
      id: json['id']?.toString() ?? '',
      tripId: json['tripId']?.toString() ?? json['trip_id']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      speedKmh:
          (json['speedKmh'] as num? ?? json['speed_kmh'] as num?)?.toDouble() ??
          0.0,
      heading: (json['heading'] as num?)?.toDouble() ?? 0.0,
      recordedAt:
          json['recordedAt']?.toString() ?? json['recorded_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'trip_id': tripId,
    'latitude': latitude,
    'longitude': longitude,
    'speed_kmh': speedKmh,
    'heading': heading,
    'recorded_at': recordedAt,
  };
}
