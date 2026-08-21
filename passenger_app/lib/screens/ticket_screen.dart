import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../controllers/auth_controller.dart' show bookingRepositoryProvider;
import '../controllers/ticket_controller.dart';
import '../routes/app_routes.dart';
import '../theme/design_tokens.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/polished_button.dart';
import '../widgets/polished_card.dart';
import '../widgets/skeleton_list.dart';
import '../widgets/status_badge.dart';

/// Ticket Screen displaying generated ticket and QR code.
class TicketScreen extends ConsumerStatefulWidget {
  const TicketScreen({super.key});

  @override
  ConsumerState<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends ConsumerState<TicketScreen> {
  String? _bookingId;
  String? _tripId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bookingId ??= ModalRoute.of(context)?.settings.arguments as String?;
  }

  Future<void> _handleGenerateTicket() async {
    if (_bookingId == null) return;
    await ref
        .read(ticketControllerProvider.notifier)
        .generateTicket(_bookingId!);
    if (_tripId == null && mounted) {
      try {
        final booking =
            await ref.read(bookingRepositoryProvider).getBooking(_bookingId!);
        if (mounted) setState(() => _tripId = booking.tripId);
      } catch (_) {
        // Non-fatal — Track button just won't be shown.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketState = ref.watch(ticketControllerProvider);
    final isLoading = ticketState.isLoading && ticketState.result == null;

    return AppScaffold(
      title: 'Digital Ticket',
      centerTitle: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Booking ID: ${_bookingId ?? 'N/A'}',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.spaceLg),
            if (isLoading) ...[
              const SkeletonBlock(height: 280),
              const SizedBox(height: DesignTokens.spaceLg),
            ] else if (ticketState.result != null) ...[
              PolishedCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (ticketState.result!.qrCodeData != null &&
                        ticketState.result!.qrCodeData!.isNotEmpty)
                      QrImageView(
                        key: const Key('ticket_qr'),
                        data: ticketState.result!.qrCodeData!,
                        version: QrVersions.auto,
                        size: 200.0,
                      )
                    else
                      Container(
                        key: const Key('ticket_qr'),
                        width: 200,
                        height: 200,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(DesignTokens.radiusGlobal),
                        ),
                        child: Text(
                          ticketState.result!.ticket.id,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: DesignTokens.spaceMd),
                    StatusBadge(status: ticketState.result!.ticket.status),
                    if (ticketState.result!.ticket.issuedAt != null) ...[
                      const SizedBox(height: DesignTokens.spaceXs),
                      Text(
                        'Issued: ${ticketState.result!.ticket.issuedAt}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.spaceLg),
            ],
            if (ticketState.errorMessage != null) ...[
              Text(
                ticketState.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignTokens.spaceMd),
            ],
            PolishedButton(
              key: const Key('generate_ticket_button'),
              label: ticketState.result == null ? 'Generate Ticket' : 'Re-generate Ticket',
              isLoading: ticketState.isLoading,
              onPressed: _bookingId != null ? _handleGenerateTicket : null,
            ),
            if (_tripId != null) ...[
              const SizedBox(height: DesignTokens.spaceSm),
              PolishedButton(
                key: const Key('track_live_location_button'),
                label: 'Track Live Location',
                variant: PolishedButtonVariant.secondary,
                icon: Icons.map_rounded,
                onPressed: () => AppRoutes.navigateToTracking(context, _tripId!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
