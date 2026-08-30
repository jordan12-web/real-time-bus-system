/// Matches the actual backend response from POST /tickets/validate
/// (verified against backend/src/services/ticketService.js), which returns
/// `{ valid, reason?, ticket? }` — NOT `{ valid, message, bookingId, used }`
/// as an earlier spec assumed. Modeling against the real shape here so this
/// doesn't silently show blank fields against the live backend.
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

  /// booking_id, if the backend included the ticket object in the response
  /// (it does on used/revoked/success cases, not on malformed-QR cases).
  String? get bookingId => ticket?['booking_id']?.toString();

  String? get ticketStatus => ticket?['status']?.toString();
}