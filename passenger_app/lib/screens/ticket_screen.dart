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

/// Digital Boarding Pass Ticket Screen with QR Code and Live Tracking shortcut.
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
    final newId = ModalRoute.of(context)?.settings.arguments as String?;
    if (newId != null && newId != _bookingId) {
      _bookingId = newId;
      // Auto-load/generate ticket if available
      Future.microtask(() => _handleGenerateTicket());
    }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? DesignTokens.darkPrimary : DesignTokens.primary;
    final cardBg = isDark ? const Color(0xFF131D31) : Colors.white;

    return AppScaffold(
      title: 'Digital Boarding Pass',
      centerTitle: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isLoading) ...[
              const SkeletonBlock(height: 360),
              const SizedBox(height: DesignTokens.spaceLg),
            ] else if (ticketState.result != null) ...[
              // ── Boarding Pass Card ───────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius:
                      BorderRadius.circular(DesignTokens.radiusGlobal + 4),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                  boxShadow: DesignTokens.cardShadow(),
                ),
                child: Column(
                  children: [
                    // Top header strip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spaceMd,
                        vertical: DesignTokens.spaceSm,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primary.withValues(alpha: 0.15),
                            primary.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(DesignTokens.radiusGlobal + 2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.confirmation_number_rounded,
                                size: 18,
                                color: primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'GUZO BOARDING PASS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                  color: primary,
                                ),
                              ),
                            ],
                          ),
                          StatusBadge(status: ticketState.result!.ticket.status),
                        ],
                      ),
                    ),

                    // QR Code Frame
                    Padding(
                      padding: const EdgeInsets.all(DesignTokens.spaceLg),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ticketState.result!.qrCodeData != null &&
                                    ticketState.result!.qrCodeData!.isNotEmpty
                                ? QrImageView(
                                    key: const Key('ticket_qr'),
                                    data: ticketState.result!.qrCodeData!,
                                    version: QrVersions.auto,
                                    size: 190.0,
                                  )
                                : Container(
                                    key: const Key('ticket_qr'),
                                    width: 190,
                                    height: 190,
                                    alignment: Alignment.center,
                                    child: Text(
                                      ticketState.result!.ticket.id,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: DesignTokens.spaceSm),
                          Text(
                            'Scan at bus entrance door',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white60
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Perforated tear line divider
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isDark
                                ? DesignTokens.darkBackground
                                : DesignTokens.backgroundStart,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(12),
                            ),
                          ),
                        ),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final count = (constraints.maxWidth / 8).floor();
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                  count,
                                  (_) => Text(
                                    '-',
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFCBD5E1),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          width: 12,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isDark
                                ? DesignTokens.darkBackground
                                : DesignTokens.backgroundStart,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Ticket metadata details
                    Padding(
                      padding: const EdgeInsets.all(DesignTokens.spaceMd),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'BOOKING ID',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF94A3B8),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _bookingId ?? 'N/A',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              if (ticketState.result!.ticket.issuedAt != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'ISSUED AT',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF94A3B8),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      ticketState.result!.ticket.issuedAt!
                                          .toString()
                                          .split('T')[0],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.spaceLg),
            ] else ...[
              // Fallback before generation
              PolishedCard(
                child: Padding(
                  padding: const EdgeInsets.all(DesignTokens.spaceLg),
                  child: Column(
                    children: [
                      Icon(
                        Icons.qr_code_2_rounded,
                        size: 64,
                        color: primary,
                      ),
                      const SizedBox(height: DesignTokens.spaceMd),
                      Text(
                        'Ready to Generate Ticket',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spaceXs),
                      Text(
                        'Your payment is confirmed. Click below to generate your secure digital QR ticket.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.spaceLg),
            ],

            if (ticketState.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(DesignTokens.spaceSm),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .error
                      .withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(DesignTokens.radiusGlobal),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .error
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  ticketState.errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: DesignTokens.spaceMd),
            ],

            // Action Buttons
            PolishedButton(
              key: const Key('generate_ticket_button'),
              label: ticketState.result == null
                  ? 'Generate Boarding Pass'
                  : 'Re-generate QR Code',
              icon: Icons.qr_code_rounded,
              isLoading: ticketState.isLoading,
              onPressed: _bookingId != null ? _handleGenerateTicket : null,
            ),

            if (_tripId != null) ...[
              const SizedBox(height: DesignTokens.spaceSm),
              PolishedButton(
                key: const Key('track_live_location_button'),
                label: 'Track Bus Live GPS',
                variant: PolishedButtonVariant.secondary,
                icon: Icons.near_me_rounded,
                onPressed: () =>
                    AppRoutes.navigateToTracking(context, _tripId!),
              ),
            ],

            const SizedBox(height: DesignTokens.spaceSm),
            TextButton.icon(
              onPressed: () => AppRoutes.navigateToTripList(context),
              icon: const Icon(Icons.home_rounded, size: 18),
              label: const Text('Back to Trips'),
            ),
          ],
        ),
      ),
    );
  }
}
