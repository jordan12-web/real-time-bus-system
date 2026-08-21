import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/booking_controller.dart';
import '../models/trip.dart';
import '../routes/app_routes.dart';
import '../theme/design_tokens.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/bus_seat_map.dart';
import '../widgets/polished_button.dart';
import '../widgets/polished_card.dart';

/// Seat Selection & Booking confirmation screen.
class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  String? _selectedSeat;

  @override
  Widget build(BuildContext context) {
    final trip = ModalRoute.of(context)?.settings.arguments as Trip?;
    final bookingState = ref.watch(bookingControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? DesignTokens.darkPrimary : DesignTokens.primary;

    if (trip == null) {
      return const AppScaffold(
        title: 'Select Seat',
        child: Center(child: Text('Invalid trip selection.')),
      );
    }

    return AppScaffold(
      title: 'Select Seat',
      centerTitle: false,
      child: Column(
        children: [
          // ── Trip Header Summary ──────────────────────────────────────────
          PolishedCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusGlobal),
                  ),
                  child: Icon(
                    Icons.route_rounded,
                    color: primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: DesignTokens.spaceSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${trip.origin} → ${trip.destination}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Route ${trip.routeId} · ${trip.pricePerSeat.toStringAsFixed(0)} ETB / seat',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.white60
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spaceSm),

          // ── Bus Cabin Seat Map ───────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: BusSeatMap(
                  totalSeats: 20,
                  selectedSeat: _selectedSeat,
                  onSeatSelected: (seatNum) {
                    setState(() => _selectedSeat = seatNum);
                    ref
                        .read(bookingControllerProvider.notifier)
                        .selectSeat(seatNum);
                  },
                ),
              ),
            ),
          ),

          // ── Bottom Summary & Confirmation Bar ────────────────────────────
          if (bookingState.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(DesignTokens.spaceSm),
              margin: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
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
                bookingState.errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          PolishedCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedSeat != null
                            ? _selectedSeat!
                            : 'No seat selected',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: _selectedSeat != null
                              ? primary
                              : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Total: ${trip.pricePerSeat.toStringAsFixed(0)} ETB',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: DesignTokens.spaceMd),
                PolishedButton(
                  key: const Key('confirm_booking_button'),
                  label: 'Proceed',
                  icon: Icons.check_circle_outline_rounded,
                  expand: false,
                  isLoading: bookingState.isLoading,
                  onPressed: _selectedSeat == null
                      ? null
                      : () async {
                          final success = await ref
                              .read(bookingControllerProvider.notifier)
                              .createBooking(trip.id,
                                  seatNumber: _selectedSeat);

                          if (success && context.mounted) {
                            final booking =
                                ref.read(bookingControllerProvider).booking;
                            if (booking != null) {
                              AppRoutes.navigateToPayment(context, booking.id);
                            }
                          }
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
