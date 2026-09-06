import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';
import '../controllers/driver_trip_controller.dart';
import '../models/trip.dart';
import '../theme/design_tokens.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/polished_button.dart';
import '../widgets/polished_card.dart';
import '../widgets/status_badge.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = ref.read(authControllerProvider).user;
      if (user != null) {
        ref.read(driverTripControllerProvider.notifier).loadMyTrips(user.id);
      }
    });
  }

  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = monthNames[local.month - 1];
    final day = local.day;
    final hour = local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$month $day, $period $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final tripState = ref.watch(driverTripControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = authState.user;

    return AppScaffold(
      title: 'Driver Dashboard',
      actions: [
        IconButton(
          key: const Key('refresh_trips_button'),
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh Trips',
          onPressed: () {
            if (user != null) {
              ref.read(driverTripControllerProvider.notifier).loadMyTrips(user.id);
            }
          },
        ),
        IconButton(
          key: const Key('logout_button'),
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Log Out',
          onPressed: () async {
            final navigator = Navigator.of(context);
            await ref.read(authControllerProvider.notifier).logout();
            navigator.pushReplacementNamed('/login');
          },
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Driver Profile Overview Card
          PolishedCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(DesignTokens.spaceSm),
                  decoration: BoxDecoration(
                    color: (isDark ? DesignTokens.darkPrimary : DesignTokens.primary)
                        .withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_circle_rounded,
                    size: 40,
                    color: isDark ? DesignTokens.darkPrimary : DesignTokens.primary,
                  ),
                ),
                const SizedBox(width: DesignTokens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.email ?? 'Active Driver',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Role: Driver / Operator',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spaceSm,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: DesignTokens.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: DesignTokens.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Online',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? DesignTokens.darkPrimary : DesignTokens.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),

          // Quick Actions Row
          Row(
            children: [
              Expanded(
                child: PolishedButton(
                  buttonKey: const Key('create_trip_button'),
                  label: 'Create Trip',
                  icon: Icons.add_circle_outline_rounded,
                  variant: PolishedButtonVariant.primary,
                  onPressed: () => Navigator.of(context).pushNamed('/create_trip'),
                ),
              ),
              const SizedBox(width: DesignTokens.spaceSm),
              Expanded(
                child: PolishedButton(
                  buttonKey: const Key('scan_qr_button'),
                  label: 'Scan Ticket',
                  icon: Icons.qr_code_scanner_rounded,
                  variant: PolishedButtonVariant.secondary,
                  onPressed: () => Navigator.of(context).pushNamed('/scan_qr'),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceLg),

          // Trips Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Assigned Trips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? DesignTokens.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  '${tripState.trips.length} ${tripState.trips.length == 1 ? 'Trip' : 'Trips'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceSm),

          // Error Notification Banner
          if (tripState.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(DesignTokens.spaceSm),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusGlobal),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tripState.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.spaceSm),
          ],

          // Trip List
          Expanded(
            child: tripState.isLoading && tripState.trips.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : tripState.trips.isEmpty
                    ? PolishedCard(
                        padding: const EdgeInsets.all(DesignTokens.spaceXl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions_bus_outlined,
                              size: 56,
                              color: isDark ? Colors.white38 : Colors.grey.shade400,
                            ),
                            const SizedBox(height: DesignTokens.spaceMd),
                            Text(
                              'No trips assigned yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: DesignTokens.spaceXs),
                            Text(
                              'Tap "Create Trip" above to schedule your first intercity route and broadcast live location.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        key: const Key('trip_list'),
                        itemCount: tripState.trips.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: DesignTokens.spaceSm),
                        itemBuilder: (context, index) {
                          final Trip trip = tripState.trips[index];
                          return PolishedCard(
                            cardKey: Key('trip_item_${trip.id}'),
                            onTap: () => Navigator.of(context).pushNamed(
                              '/trip_detail',
                              arguments: trip.id,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top row: Route origin -> destination + Status
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.trip_origin_rounded,
                                            size: 18,
                                            color: isDark
                                                ? DesignTokens.darkPrimary
                                                : DesignTokens.primary,
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              trip.origin,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 6),
                                            child: Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Icon(
                                            Icons.location_on_rounded,
                                            size: 18,
                                            color: isDark
                                                ? DesignTokens.darkAccent
                                                : DesignTokens.accent,
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              trip.destination,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    StatusBadge(status: trip.status),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: DesignTokens.spaceSm),
                                  child: Divider(height: 1),
                                ),

                                // Metadata grid: Departure time, Vehicle, Price
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.schedule_rounded,
                                                size: 14,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _formatDateTime(trip.departureTime),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.directions_bus_filled_outlined,
                                                size: 14,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Vehicle: ${trip.vehicleId}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
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
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? DesignTokens.darkPrimary : DesignTokens.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(
                                              'Manage',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: isDark ? DesignTokens.darkAccent : DesignTokens.accent,
                                              ),
                                            ),
                                            const SizedBox(width: 2),
                                            Icon(
                                              Icons.chevron_right_rounded,
                                              size: 16,
                                              color: isDark ? DesignTokens.darkAccent : DesignTokens.accent,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}