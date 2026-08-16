import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:passenger_app/models/payment.dart';
import 'package:passenger_app/repositories/payment_repository.dart';
import 'package:passenger_app/services/payment_service.dart';

class MockPaymentService extends Mock implements PaymentService {}

void main() {
  group('PaymentRepository idempotency', () {
    late MockPaymentService mockService;
    late PaymentRepository repository;

    setUp(() {
      mockService = MockPaymentService();
      repository = PaymentRepository(mockService);
    });

    test(
      'TODO: returns cached pending payment without second API call',
      () async {
        // TODO: stub initiatePayment once, call repository twice, verify
        // mockService.initiatePayment called only once for same bookingId.
        const pending = Payment(
          id: 'pay-1',
          bookingId: 'booking-1',
          amount: 350,
          currency: 'ETB',
          status: 'pending',
          chapaTxRef: 'tx-ref',
          chapaCheckoutUrl: 'https://checkout.example',
        );
        expect(pending.status, 'pending');
        expect(repository, isNotNull);
      },
    );

    test('TODO: re-initiates when cached payment is not pending', () async {
      // TODO: seed cache with success payment and assert new initiate call.
      expect(mockService, isNotNull);
    });
  });
}
