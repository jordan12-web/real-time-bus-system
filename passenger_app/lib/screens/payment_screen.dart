import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../routes/app_routes.dart';
import '../controllers/payment_controller.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';
import 'chapa_checkout_screen.dart';

/// Payment Screen handling initiation and status polling.
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String? _bookingId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bookingId ??= ModalRoute.of(context)?.settings.arguments as String?;
  }

  Future<void> _handleInitiatePayment() async {
    if (_bookingId == null) return;
    final result = await ref
        .read(paymentControllerProvider.notifier)
        .initiatePayment(bookingId: _bookingId!);

    if (result != null && result.checkoutUrl.isNotEmpty && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChapaCheckoutScreen(checkoutUrl: result.checkoutUrl),
        ),
      );
      // Whether the WebView detected the return_url or the user just
      // backed out manually, check the real status now rather than
      // assuming — this is the source of truth, not the WebView nav event.
      if (mounted) {
        _startPolling(result.payment.id);
      }
    }
  }

  Future<void> _startPolling(String paymentId) async {
    final payment = await ref
        .read(paymentControllerProvider.notifier)
        .pollPaymentStatus(paymentId);

    if (payment != null && payment.status == 'success' && mounted && _bookingId != null) {
      AppRoutes.navigateToTicket(context, _bookingId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentControllerProvider);

    return AppScaffold(
      title: 'Payment',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text(
              'Booking ID: ${_bookingId ?? 'N/A'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (paymentState.initiation != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount: ${paymentState.initiation!.payment.amount} ${paymentState.initiation!.payment.currency}'),
                      const SizedBox(height: 8),
                      Text('Status: ${paymentState.payment?.status ?? paymentState.initiation!.payment.status}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (paymentState.errorMessage != null) ...[
              Text(
                paymentState.errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            PrimaryButton(
              key: const Key('pay_button'),
              text: paymentState.initiation == null ? 'Initiate Payment' : 'Re-open Checkout',
              isLoading: paymentState.isLoading,
              onPressed: _bookingId != null ? _handleInitiatePayment : null,
            ),
            const SizedBox(height: 16),
            if (paymentState.initiation != null)
              OutlinedButton(
                key: const Key('poll_status_button'),
                onPressed: paymentState.isPolling
                    ? null
                    : () {
                        _startPolling(paymentState.initiation!.payment.id);
                      },
                child: paymentState.isPolling
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2.0),
                          ),
                          SizedBox(width: 8),
                          Text('Checking Status...'),
                        ],
                      )
                    : const Text('Check Payment Status'),
              ),
          ],
        ),
      ),
    );
  }
}