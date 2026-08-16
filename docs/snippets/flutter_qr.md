# Flutter QR Code Generation & Driver Validation Snippet

This snippet demonstrates generating and displaying a passenger ticket QR code and validating a scanned QR code in the Driver App.

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TicketService {
  static const String baseUrl = 'http://localhost:3000';

  // -------------------------------------------------------------
  // Passenger App: Generate & Fetch QR Code
  // -------------------------------------------------------------
  Future<Map<String, dynamic>> generateTicket(String bookingId, String accessToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tickets/$bookingId/generate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Ticket generation failed');
    }
  }

  // -------------------------------------------------------------
  // Driver App: Validate Scanned QR Data Payload
  // -------------------------------------------------------------
  Future<Map<String, dynamic>> validateScannedQr(String qrCodeData, String driverAccessToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tickets/validate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $driverAccessToken',
      },
      body: jsonEncode({'qr_code_data': qrCodeData}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data; // { "valid": true, "ticket": { ... } }
    } else {
      return data; // { "valid": false, "reason": "..." }
    }
  }
}

// -------------------------------------------------------------
// Passenger Widget Example: Render Ticket Image
// -------------------------------------------------------------
class TicketImageWidget extends StatelessWidget {
  final String relativeImageUrl;

  const TicketImageWidget({super.key, required this.relativeImageUrl});

  @override
  Widget build(BuildContext context) {
    final fullUrl = '${TicketService.baseUrl}$relativeImageUrl';
    return Image.network(
      fullUrl,
      width: 250,
      height: 250,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const CircularProgressIndicator();
      },
      errorBuilder: (context, error, stackTrace) => const Text('Error loading QR Ticket'),
    );
  }
}
```
