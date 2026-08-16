/// Chapa payment record — fields from OpenAPI `#/components/schemas/Payment`.
class Payment {
  final String id;
  final String bookingId;
  final double amount;
  final String currency;
  final String status;
  final String chapaTxRef;
  final String? chapaCheckoutUrl;

  const Payment({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.chapaTxRef,
    this.chapaCheckoutUrl,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    final bookingField = json['bookingId'] ?? json['booking_id'];
    final bookingId = bookingField is Map
        ? bookingField['id']?.toString() ?? ''
        : bookingField?.toString() ?? '';

    return Payment(
      id: json['id']?.toString() ?? json['paymentId']?.toString() ?? '',
      bookingId: bookingId,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'ETB',
      status: json['status']?.toString() ?? 'pending',
      chapaTxRef:
          json['chapaTxRef']?.toString() ??
          json['chapa_tx_ref']?.toString() ??
          '',
      chapaCheckoutUrl:
          json['chapaCheckoutUrl']?.toString() ??
          json['chapa_checkout_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'booking_id': bookingId,
    'amount': amount,
    'currency': currency,
    'status': status,
    'chapa_tx_ref': chapaTxRef,
    'chapa_checkout_url': chapaCheckoutUrl,
  };
}
