import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../widgets/app_scaffold.dart';

/// Displays the Chapa checkout page inside the app via WebView, instead of
/// handing off to an external browser. Pops itself with `true` once the
/// page navigates to a URL containing [returnUrlMarker] (Chapa's return_url
/// after a completed/cancelled attempt), so the caller can trigger a
/// payment-status poll immediately instead of waiting on a fixed interval.
class ChapaCheckoutScreen extends StatefulWidget {
  final String checkoutUrl;

  const ChapaCheckoutScreen({super.key, required this.checkoutUrl});

  /// Matches the return_url your backend sends to Chapa
  /// (see paymentService.js: 'http://localhost:3000/payments/success' by
  /// default, or PAYMENT_RETURN_URL if you've configured one).
  static const String returnUrlMarker = '/payments/success';

  @override
  State<ChapaCheckoutScreen> createState() => _ChapaCheckoutScreenState();
}

class _ChapaCheckoutScreenState extends State<ChapaCheckoutScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
            if (url.contains(ChapaCheckoutScreen.returnUrlMarker)) {
              Navigator.of(context).pop(true);
            }
          },
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (error) {
            setState(() {
              _isLoading = false;
              _loadError = error.description;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Complete Payment',
      child: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (_loadError != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Could not load the payment page: $_loadError',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}