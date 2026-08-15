import '../models/ticket.dart';
import '../services/ticket_service.dart';

/// Result of `POST /tickets/{bookingId}/generate`.
class TicketGenerationResult {
  final Ticket ticket;
  final String? qrCodeImageUrl;
  final String? qrCodeData;

  const TicketGenerationResult({
    required this.ticket,
    this.qrCodeImageUrl,
    this.qrCodeData,
  });
}

/// Idempotent ticket generation for confirmed bookings.
class TicketRepository {
  final TicketService _service;
  final Map<String, TicketGenerationResult> _issuedByBooking = {};

  TicketRepository(this._service);

  Future<TicketGenerationResult> generateTicket(String bookingId) async {
    final cached = _issuedByBooking[bookingId];
    if (cached != null && cached.ticket.status == 'issued') {
      return cached;
    }

    final raw = await _service.generateTicket(bookingId);
    final ticket = Ticket.fromJson(raw['ticket'] as Map<String, dynamic>);
    final result = TicketGenerationResult(
      ticket: ticket,
      qrCodeImageUrl: raw['qr_code_image_url']?.toString(),
      qrCodeData: raw['qr_code_data']?.toString(),
    );

    if (ticket.status == 'issued') {
      _issuedByBooking[bookingId] = result;
    }

    return result;
  }

  Future<Map<String, dynamic>> validateTicket(String qrCodeData) {
    return _service.validateTicket(qrCodeData);
  }

  Future<Ticket> revokeTicket(String id) async {
    final raw = await _service.revokeTicket(id);
    if (raw['ticket'] is Map<String, dynamic>) {
      return Ticket.fromJson(raw['ticket'] as Map<String, dynamic>);
    }
    return Ticket.fromJson(raw);
  }
}
