import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Displays the Chapa checkout page inside the app via WebView, instead of
/// handing off to an external browser. Pops itself with `true` once the
/// page navigates to a URL containing [returnUrlMarker] (Chapa's return_url
/// after a completed/cancelled attempt), so the caller can trigger a
/// payment-status poll immediately instead of waiting on a fixed interval.
///
/// Deliberately uses a plain Scaffold (not the shared AppScaffold) — that
/// widget wraps its child in 16px of padding on every side, which is right
/// for forms/text but leaves a WebView floating in a boxed-in area in the
/// middle of the screen instead of filling it edge-to-edge.
class ChapaCheckoutScreen extends StatefulWidget {
  final String checkoutUrl;

  const ChapaCheckoutScreen({super.key, required this.checkoutUrl});

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
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Payment')),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: WebViewWidget(controller: _controller)),
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
      ),
    );
  }
}