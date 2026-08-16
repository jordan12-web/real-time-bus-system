# Flutter Chapa Payment Integration Snippet

This snippet demonstrates initiating a payment for a booking, launching Chapa's checkout URL using `url_launcher`, and polling payment status until confirmed.

```dart
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  static const String baseUrl = 'http://localhost:3000';

  // Step 1: Initiate Payment & Get Checkout URL
  Future<String> initiatePayment(String bookingId, String accessToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments/initiate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'bookingId': bookingId,
        'return_url': 'http://localhost:3000/payments/success',
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final checkoutUrl = data['checkout_url'];
      
      // Step 2: Open Checkout URL in External Browser or Webview
      final uri = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      
      return data['payment']['id'];
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to initiate payment');
    }
  }

  // Step 3: Poll Payment Status until confirmed/failed
  Future<bool> pollPaymentStatus(String paymentId, String accessToken, {int maxAttempts = 12}) async {
    int attempts = 0;
    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 3));
      attempts++;

      final response = await http.get(
        Uri.parse('$baseUrl/payments/$paymentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final payment = data['payment'];
        final status = payment['status'];

        if (status == 'success') {
          return true;
        } else if (status == 'failed') {
          return false;
        }
      }
    }
    return false;
  }
}
```
