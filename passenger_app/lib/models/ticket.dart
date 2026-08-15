/// QR ticket — fields from OpenAPI `#/components/schemas/Ticket`.
class Ticket {
  final String id;
  final String bookingId;
  final String qrCodeData;
  final String? qrCodeImageUrl;
  final String status;
  final String? issuedAt;
  final String? usedAt;
  final String? revokedAt;

  const Ticket({
    required this.id,
    required this.bookingId,
    required this.qrCodeData,
    this.qrCodeImageUrl,
    required this.status,
    this.issuedAt,
    this.usedAt,
    this.revokedAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      qrCodeData: json['qr_code_data']?.toString() ?? '',
      qrCodeImageUrl: json['qr_code_image_url']?.toString(),
      status: json['status']?.toString() ?? 'issued',
      issuedAt: json['issued_at']?.toString(),
      usedAt: json['used_at']?.toString(),
      revokedAt: json['revoked_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'booking_id': bookingId,
        'qr_code_data': qrCodeData,
        'qr_code_image_url': qrCodeImageUrl,
        'status': status,
        'issued_at': issuedAt,
        'used_at': usedAt,
        'revoked_at': revokedAt,
      };
}
