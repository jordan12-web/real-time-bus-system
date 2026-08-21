import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';
import '../controllers/trip_controller.dart';
import '../routes/app_routes.dart';
import '../theme/design_tokens.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/polished_button.dart';
import '../widgets/polished_card.dart';
import '../widgets/skeleton_list.dart';
import '../widgets/status_badge.dart';

/// Home screen — searchable trip list (TripListScreen).
class TripListScreen extends ConsumerStatefulWidget {
  const TripListScreen({super.key});

  @override
  ConsumerState<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends ConsumerState<TripListScreen> {
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(tripControllerProvider.notifier).loadTrips();
    });
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _onSearch() {
    ref.read(tripControllerProvider.notifier).searchTrips(
          origin: _originController.text.trim(),
          destination: _destinationController.text.trim(),
        );
  }

  String _formatDeparture(DateTime time) {
    final local = time.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(tripControllerProvider);

    return AppScaffold(
      title: 'Available Bus Trips',
      actions: [
        IconButton(
          key: const Key('refresh_trips_button'),
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh trips',
          onPressed: () {
            ref.read(tripControllerProvider.notifier).loadTrips(forceRefresh: true);
          },
        ),
        IconButton(
          key: const Key('my_trips_button'),
          icon: const Icon(Icons.confirmation_number_rounded),
          tooltip: 'My Trips',
          onPressed: () => AppRoutes.navigateToMyTrips(context),
        ),
        IconButton(
          key: const Key('logout_button'),
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Log out',
          onPressed: () async {
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Log Out'),
                content: const Text('Are you sure you want to log out?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(ctx).colorScheme.error,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Log Out'),
                  ),
                ],
              ),
            );

            if (shouldLogout == true && context.mounted) {
              final navigator = Navigator.of(context);
              await ref.read(authControllerProvider.notifier).logout();
              navigator.pushReplacementNamed(AppRoutes.login);
            }
          },
        ),
      ],
      child: Column(
        children: [
          PolishedCard(
            child: Column(
              children: [
                TextField(
                  key: const Key('search_origin_input'),
                  controller: _originController,
                  decoration: const InputDecoration(
                    labelText: 'Origin (e.g. Addis Ababa)',
                    prefixIcon: Icon(Icons.location_on_rounded),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceXs),
                TextField(
                  key: const Key('search_destination_input'),
                  controller: _destinationController,
                  decoration: const InputDecoration(
                    labelText: 'Destination (e.g. Hawassa)',
                    prefixIcon: Icon(Icons.flag_rounded),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceSm),
                PolishedButton(
                  key: const Key('search_button'),
                  label: 'Search Trips',
                  icon: Icons.search_rounded,
                  onPressed: _onSearch,
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          Expanded(
            child: tripState.isLoading
                ? const SkeletonList(itemCount: 6)
                : tripState.errorMessage != null
                    ? Center(
                        child: Text(
                          tripState.errorMessage!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      )
                    : tripState.trips.isEmpty
                        ? Center(
                            child: Text(
                              'No trips found for selected route.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              ref.read(tripControllerProvider.notifier).loadTrips(forceRefresh: true);
                            },
                            child: ListView.separated(
                              key: const Key('trip_list'),
                              itemCount: tripState.trips.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: DesignTokens.spaceSm),
                              itemBuilder: (context, index) {
                              final trip = tripState.trips[index];
                              return PolishedCard(
                                key: Key('trip_item_${trip.id}'),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.tripDetail,
                                    arguments: trip,
                                  );
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.directions_bus_rounded,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: DesignTokens.spaceSm),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${trip.origin} → ${trip.destination}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Departs ${_formatDeparture(trip.departureTime)}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${trip.pricePerSeat.toStringAsFixed(0)} ETB',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Theme.of(context).colorScheme.secondary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        StatusBadge(status: trip.status),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
          ),
        ],
      ),
    );
  }
}
