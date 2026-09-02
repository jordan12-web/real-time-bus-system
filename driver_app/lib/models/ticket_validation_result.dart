
class TicketValidationResult {
  final bool valid;
  final String? reason;
  final Map<String, dynamic>? ticket;

  TicketValidationResult({required this.valid, this.reason, this.ticket});

  factory TicketValidationResult.fromJson(Map<String, dynamic> json) {
    return TicketValidationResult(
      valid: json['valid'] == true,
      reason: json['reason']?.toString(),
      ticket: json['ticket'] as Map<String, dynamic>?,
    );
  }


  String? get bookingId => ticket?['booking_id']?.toString();

  String? get ticketStatus => ticket?['status']?.toString();
}