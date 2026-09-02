class Trip {
  final String id;
  final String routeId;
  final String origin;
  final String destination;
  final String vehicleId;
  final String driverId;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double pricePerSeat;
  final String status;

  Trip({
    required this.id,
    required this.routeId,
    required this.origin,
    required this.destination,
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
      routeId: json['route_id']?.toString() ?? '',
      origin: json['origin']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
      vehicleId: json['vehicle_id']?.toString() ?? '',
      driverId: json['driver_id']?.toString() ?? '',
      departureTime: DateTime.tryParse(json['departure_time']?.toString() ?? '') ??
          DateTime.now(),
      arrivalTime: DateTime.tryParse(json['arrival_time']?.toString() ?? '') ??
          DateTime.now(),
      pricePerSeat: (json['price_per_seat'] as num?)?.toDouble() ?? 0.0,
      
      status: json['status']?.toString() ?? 'scheduled',
    );
  }
}