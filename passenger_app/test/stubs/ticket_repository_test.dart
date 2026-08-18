import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:passenger_app/models/ticket.dart';
import 'package:passenger_app/repositories/ticket_repository.dart';
import 'package:passenger_app/services/ticket_service.dart';

class MockTicketService extends Mock implements TicketService {}

void main() {
  group('TicketRepository idempotency', () {
    late MockTicketService mockService;
    late TicketRepository repository;

    setUp(() {
      mockService = MockTicketService();
      repository = TicketRepository(mockService);
    });

    test('TODO: returns cached issued ticket without second API call', () async {
      // TODO: stub generateTicket once, call repository twice, verify
      // mockService.generateTicket called only once for same bookingId.
      const issued = Ticket(
        id: 'ticket-1',
        bookingId: 'booking-1',
        qrCodeData: 'signed-payload',
        status: 'issued',
      );
      expect(issued.status, 'issued');
      expect(repository, isNotNull);
    });

    test('TODO: re-generates when cached ticket is not issued', () async {
      // TODO: seed cache with a revoked/used ticket and assert a new
      // generateTicket call is made instead of returning the stale cache.
      expect(mockService, isNotNull);
    });
  });
}