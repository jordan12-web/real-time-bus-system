import '../models/payment.dart';
import '../services/payment_service.dart';

/// Result of `POST /payments/initiate`.
class PaymentInitiationResult {
  final String checkoutUrl;
  final Payment payment;

  const PaymentInitiationResult({
    required this.checkoutUrl,
    required this.payment,
  });
}

/// Idempotent payment initiation for a booking.
class PaymentRepository {
  final PaymentService _service;
  final Map<String, PaymentInitiationResult> _pendingByBooking = {};

  PaymentRepository(this._service);

  Future<PaymentInitiationResult> initiatePayment({
    required String bookingId,
    String? returnUrl,
  }) async {
    final cached = _pendingByBooking[bookingId];
    if (cached != null && cached.payment.status == 'pending') {
      return cached;
    }

    final raw = await _service.initiatePayment(
      bookingId: bookingId,
      returnUrl: returnUrl,
    );

    final payment = Payment.fromJson(raw['payment'] as Map<String, dynamic>);
    final checkoutUrl = raw['checkout_url']?.toString() ?? '';
    final result = PaymentInitiationResult(
      checkoutUrl: checkoutUrl,
      payment: payment,
    );

    if (payment.status == 'pending') {
      _pendingByBooking[bookingId] = result;
    }

    return result;
  }

  Future<Payment> getPayment(String id) async {
    final raw = await _service.getPayment(id);
    return Payment.fromJson(raw['payment'] as Map<String, dynamic>);
  }

  void clearPendingCache(String bookingId) => _pendingByBooking.remove(bookingId);
}
