/// Seat reservation — fields from OpenAPI `#/components/schemas/Booking`.
class Booking {
  final String id;
  final String userId;
  final String tripId;
  final String status;
  final double totalAmount;
  final String currency;
  final String? holdExpiresAt;

  const Booking({
    required this.id,
    required this.userId,
    required this.tripId,
    required this.status,
    required this.totalAmount,
    required this.currency,
    this.holdExpiresAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id']?.toString() ?? json['bookingId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      tripId: json['tripId']?.toString() ?? json['trip_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      totalAmount:
          (json['totalAmount'] as num? ?? json['total_amount'] as num?)
              ?.toDouble() ??
          0.0,
      currency: json['currency']?.toString() ?? 'ETB',
      holdExpiresAt:
          json['holdExpiresAt']?.toString() ??
          json['hold_expires_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'trip_id': tripId,
    'status': status,
    'total_amount': totalAmount,
    'currency': currency,
    'hold_expires_at': holdExpiresAt,
  };
}
