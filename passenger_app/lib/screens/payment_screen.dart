import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../routes/app_routes.dart';
import '../controllers/payment_controller.dart';
import '../theme/design_tokens.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/polished_button.dart';
import '../widgets/polished_card.dart';
import '../widgets/status_badge.dart';

import 'chapa_checkout_screen.dart'
    if (dart.library.html) 'chapa_checkout_screen_stub.dart';

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

    if (result == null || result.checkoutUrl.isEmpty || !mounted) return;

    if (kIsWeb) {
      // On web: open Chapa in a new browser tab
      final uri = Uri.parse(result.checkoutUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, webOnlyWindowName: '_blank');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open payment page. Please try again.'),
            ),
          );
        }
        return;
      }

      await Future<void>.delayed(const Duration(seconds: 5));
      if (mounted) _startPolling(result.payment.id);
    } else {
      // On mobile: push WebView screen
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChapaCheckoutScreen(checkoutUrl: result.checkoutUrl),
        ),
      );
      if (mounted) _startPolling(result.payment.id);
    }
  }

  Future<void> _startPolling(String paymentId) async {
    final payment = await ref
        .read(paymentControllerProvider.notifier)
        .pollPaymentStatus(paymentId);

    if (payment != null &&
        payment.status == 'success' &&
        mounted &&
        _bookingId != null) {
      AppRoutes.navigateToTicket(context, _bookingId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentControllerProvider);
    final status = paymentState.payment?.status ??
        paymentState.initiation?.payment.status ??
        'pending';

    return AppScaffold(
      title: 'Payment',
      centerTitle: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Booking ID: ${_bookingId ?? 'N/A'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: DesignTokens.spaceMd),

            // Info banner for web
            if (kIsWeb)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.open_in_new, size: 18, color: Colors.amber),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Payment will open in a new browser tab. Come back here after completing payment and tap "Check Payment Status".',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            if (kIsWeb) const SizedBox(height: DesignTokens.spaceMd),

            if (paymentState.initiation != null)
              PolishedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${paymentState.initiation!.payment.amount} ${paymentState.initiation!.payment.currency}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                        StatusBadge(status: status),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.spaceXs),
                    Text(
                      'Complete payment to confirm your seat.',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: DesignTokens.spaceMd),

            if (paymentState.errorMessage != null) ...[
              Text(
                paymentState.errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignTokens.spaceMd),
            ],

            PolishedButton(
              key: const Key('pay_button'),
              label: paymentState.initiation == null
                  ? 'Initiate Payment'
                  : 'Re-open Checkout',
              isLoading: paymentState.isLoading,
              icon: Icons.payment_rounded,
              onPressed: _bookingId != null ? _handleInitiatePayment : null,
            ),
            const SizedBox(height: DesignTokens.spaceMd),

            if (paymentState.initiation != null)
              PolishedButton(
                key: const Key('poll_status_button'),
                label: paymentState.isPolling
                    ? 'Checking Status...'
                    : 'Check Payment Status',
                variant: PolishedButtonVariant.secondary,
                isLoading: paymentState.isPolling,
                onPressed: paymentState.isPolling
                    ? null
                    : () => _startPolling(paymentState.initiation!.payment.id),
              ),
          ],
        ),
      ),
    );
  }
}
