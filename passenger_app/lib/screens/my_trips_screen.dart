import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart' show tripRepositoryProvider;
import '../controllers/my_bookings_controller.dart';
import '../models/booking.dart';
import '../models/trip.dart';
import '../routes/app_routes.dart';
import '../theme/design_tokens.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/polished_button.dart';
import '../widgets/polished_card.dart';
import '../widgets/skeleton_list.dart';
import '../widgets/status_badge.dart';

class MyTripsScreen extends ConsumerStatefulWidget {
  const MyTripsScreen({super.key});

  @override
  ConsumerState<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends ConsumerState<MyTripsScreen> {
  /// UI-only trip cache — enriches booking rows without touching controllers.
  final Map<String, Trip> _tripCache = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(myBookingsControllerProvider.notifier).loadMyBookings();
    });
  }

  Future<void> _loadTripDetails(List<Booking> bookings) async {
    final repo = ref.read(tripRepositoryProvider);
    final missing = bookings
        .map((b) => b.tripId)
        .where((id) => id.isNotEmpty && !_tripCache.containsKey(id))
        .toSet();

    if (missing.isEmpty) return;

    await Future.wait(missing.map((tripId) async {
      try {
        final trip = await repo.getTrip(tripId);
        if (mounted) setState(() => _tripCache[tripId] = trip);
      } catch (_) {
        // Non-fatal — row falls back to trip ID label.
      }
    }));
  }

  String _formatDeparture(Trip? trip) {
    if (trip == null) return 'Departure time unavailable';
    final local = trip.departureTime.toLocal();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekday = weekdays[local.weekday - 1];
    final month = months[local.month - 1];
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$weekday, $month ${local.day} · $hour:$minute';
  }

  String? _formatEta(Trip? trip) {
    if (trip == null) return null;
    final local = trip.arrivalTime.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return 'ETA $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myBookingsControllerProvider);

    if (state.bookings.isNotEmpty) {
      // Fire-and-forget enrichment; does not alter booking controller state.
      _loadTripDetails(state.bookings);
    }

    return AppScaffold(
      title: 'My Trips',
      actions: [
        IconButton(
          key: const Key('refresh_my_trips_button'),
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh',
          onPressed: () {
            ref.read(myBookingsControllerProvider.notifier).loadMyBookings();
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          if (state.isLoading && state.bookings.isEmpty) {
            return const SkeletonList(itemCount: 5);
          }
          if (state.errorMessage != null && state.bookings.isEmpty) {
            return Center(
              child: Text(
                state.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            );
          }
          if (state.bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.directions_bus_rounded,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: DesignTokens.spaceMd),
                  const Text(
                    'No trips yet',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: DesignTokens.spaceXs),
                  Text(
                    'Book a route to see your trips here.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(myBookingsControllerProvider.notifier).loadMyBookings(),
            child: ListView.separated(
              key: const Key('my_trips_list'),
              itemCount: state.bookings.length,
              separatorBuilder: (context, index) => const SizedBox(height: DesignTokens.spaceSm),
              itemBuilder: (context, index) {
                final booking = state.bookings[index];
                final trip = _tripCache[booking.tripId];
                return _MyTripListItem(
                  key: Key('my_trip_item_${booking.id}'),
                  booking: booking,
                  trip: trip,
                  departureLabel: _formatDeparture(trip),
                  etaLabel: _formatEta(trip),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _MyTripListItem extends StatelessWidget {
  final Booking booking;
  final Trip? trip;
  final String departureLabel;
  final String? etaLabel;

  const _MyTripListItem({
    super.key,
    required this.booking,
    required this.trip,
    required this.departureLabel,
    this.etaLabel,
  });

  @override
  Widget build(BuildContext context) {
    final routeLabel = trip != null
        ? '${trip!.origin} → ${trip!.destination}'
        : 'Trip ${booking.tripId}';

    return PolishedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.route_rounded,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: DesignTokens.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routeLabel,
                      key: Key('my_trip_route_${booking.id}'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      departureLabel,
                      key: Key('my_trip_departure_${booking.id}'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: booking.status),
            ],
          ),
          if (etaLabel != null) ...[
            const SizedBox(height: DesignTokens.spaceXs),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  etaLabel!,
                  key: Key('my_trip_eta_${booking.id}'),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          if (booking.seatNumber != null) ...[
            const SizedBox(height: DesignTokens.spaceXs),
            Text('Seat ${booking.seatNumber}'),
          ],
          const SizedBox(height: DesignTokens.spaceXs),
          Text(
            '${booking.totalAmount.toStringAsFixed(2)} ${booking.currency}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          if (booking.status == 'pending')
            PolishedButton(
              key: Key('pay_now_${booking.id}'),
              label: 'Pay Now',
              expand: false,
              onPressed: () => AppRoutes.navigateToPayment(context, booking.id),
            ),
          if (booking.status == 'confirmed')
            PolishedButton(
              key: Key('view_ticket_${booking.id}'),
              label: 'View Ticket',
              variant: PolishedButtonVariant.secondary,
              expand: false,
              onPressed: () => AppRoutes.navigateToTicket(context, booking.id),
            ),
        ],
      ),
    );
  }
}
