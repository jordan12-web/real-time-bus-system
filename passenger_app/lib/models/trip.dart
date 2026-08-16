/// Scheduled trip — fields from OpenAPI `#/components/schemas/Trip`.
class Trip {
  final String id;
  final String routeId;
  final String vehicleId;
  final String driverId;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double pricePerSeat;
  final String status;

  const Trip({
    required this.id,
    required this.routeId,
    required this.vehicleId,
    required this.driverId,
    required this.departureTime,
    required this.arrivalTime,
    required this.pricePerSeat,
    required this.status,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id']?.toString() ?? '',
      routeId:
          json['routeId']?.toString() ?? json['route_id']?.toString() ?? '',
      vehicleId:
          json['vehicleId']?.toString() ?? json['vehicle_id']?.toString() ?? '',
      driverId:
          json['driverId']?.toString() ?? json['driver_id']?.toString() ?? '',
      departureTime: DateTime.parse(
        json['departureTime']?.toString() ??
            json['departure_time']?.toString() ??
            DateTime.now().toIso8601String(),
      ),
      arrivalTime: DateTime.parse(
        json['arrivalTime']?.toString() ??
            json['arrival_time']?.toString() ??
            DateTime.now().toIso8601String(),
      ),
      pricePerSeat:
          (json['pricePerSeat'] as num? ?? json['price_per_seat'] as num?)
              ?.toDouble() ??
          0.0,
      status: json['status']?.toString() ?? 'scheduled',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'route_id': routeId,
    'vehicle_id': vehicleId,
    'driver_id': driverId,
    'departure_time': departureTime.toIso8601String(),
    'arrival_time': arrivalTime.toIso8601String(),
    'price_per_seat': pricePerSeat,
    'status': status,
  };
}
