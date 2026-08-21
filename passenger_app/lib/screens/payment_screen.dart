import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../routes/app_routes.dart';
import '../controllers/payment_controller.dart';
import '../theme/design_tokens.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/polished_button.dart';
import '../widgets/polished_card.dart';
import '../widgets/status_badge.dart';
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
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: DesignTokens.spaceMd),
            if (paymentState.errorMessage != null) ...[
              Text(
                paymentState.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignTokens.spaceMd),
            ],
            PolishedButton(
              key: const Key('pay_button'),
              label: paymentState.initiation == null ? 'Initiate Payment' : 'Re-open Checkout',
              isLoading: paymentState.isLoading,
              icon: Icons.payment_rounded,
              onPressed: _bookingId != null ? _handleInitiatePayment : null,
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            if (paymentState.initiation != null)
              PolishedButton(
                key: const Key('poll_status_button'),
                label: paymentState.isPolling ? 'Checking Status...' : 'Check Payment Status',
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
