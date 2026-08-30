import 'package:flutter/material.dart';

class ChapaCheckoutScreen extends StatelessWidget {
  final String checkoutUrl;
  const ChapaCheckoutScreen({super.key, required this.checkoutUrl});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('WebView not supported on web.')),
    );
  }
}