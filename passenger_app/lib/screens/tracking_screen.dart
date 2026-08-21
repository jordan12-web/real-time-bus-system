import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/auth_controller.dart' show tripRepositoryProvider;
import '../controllers/tracking_controller.dart';
import '../core/city_coordinates.dart';
import '../models/trip.dart';
import '../models/trip_location.dart';
import '../theme/design_tokens.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/polished_card.dart';

/// Live Tracking screen with map, ETA, and last update time.
class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  String? _tripId;
  Trip? _trip;
  bool _loadingTrip = false;
  final MapController _mapController = MapController();
  bool _showList = false;

  static const _distance = Distance();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_tripId == null) {
      _tripId = ModalRoute.of(context)?.settings.arguments as String?;
      if (_tripId != null) {
        Future.microtask(() async {
          ref.read(trackingControllerProvider.notifier).loadRecentLocations(_tripId!);
          ref.read(trackingControllerProvider.notifier).subscribeLiveTracking(_tripId!);
          setState(() => _loadingTrip = true);
          try {
            final trip = await ref.read(tripRepositoryProvider).getTrip(_tripId!);
            if (mounted) setState(() => _trip = trip);
          } catch (_) {
            // Non-fatal — map still works without origin/destination pins.
          } finally {
            if (mounted) setState(() => _loadingTrip = false);
          }
        });
      }
    }
  }

  String? _estimateEta(LatLng busPosition, LatLng destination, double speedKmh) {
    if (speedKmh <= 0) return null;
    final distanceKm = _distance.as(LengthUnit.Kilometer, busPosition, destination);
    final hours = distanceKm / speedKmh;
    if (hours < 1) {
      return '${(hours * 60).round()} min';
    }
    final wholeHours = hours.floor();
    final minutes = ((hours - wholeHours) * 60).round();
    return '${wholeHours}h ${minutes}m';
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(trackingControllerProvider);

    final originLatLng = lookupCityCoordinates(_trip?.origin);
    final destinationLatLng = lookupCityCoordinates(_trip?.destination);
    final latest = trackingState.latestLocation;
    final busLatLng =
        latest != null ? LatLng(latest.latitude, latest.longitude) : null;

    final initialCenter = busLatLng ?? originLatLng ?? const LatLng(9.03, 38.74);

    String? eta;
    if (busLatLng != null && destinationLatLng != null && latest != null) {
      eta = _estimateEta(busLatLng, destinationLatLng, latest.speedKmh);
    }

    final lastUpdate = latest?.recordedAt ?? 'Waiting for update';

    return AppScaffold(
      title: _trip != null ? '${_trip!.origin} → ${_trip!.destination}' : 'Live Tracking',
      centerTitle: false,
      actions: [
        IconButton(
          key: const Key('toggle_tracking_list_button'),
          icon: Icon(_showList ? Icons.map_rounded : Icons.list_rounded),
          tooltip: _showList ? 'Show map' : 'Show list',
          onPressed: () => setState(() => _showList = !_showList),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PolishedCard(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceMd,
              vertical: DesignTokens.spaceSm,
            ),
            child: Row(
              children: [
                if (trackingState.isStreaming)
                  Row(
                    children: [
                      Icon(
                        Icons.sensors_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Live',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'Waiting for driver location...',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                const Spacer(),
                if (eta != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spaceSm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ETA $eta',
                          key: const Key('tracking_eta'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spaceXs),
          Row(
            children: [
              Icon(
                Icons.update_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Last update: $lastUpdate',
                  key: const Key('tracking_last_update'),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          if (trackingState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spaceXs),
              child: Text(
                trackingState.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(
            child: _showList
                ? _RecentLocationsList(locations: trackingState.recentLocations)
                : _loadingTrip && busLatLng == null
                    ? const Center(child: CircularProgressIndicator())
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusGlobal),
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: initialCenter,
                            initialZoom: busLatLng != null ? 12 : 6.2,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.passenger_app',
                            ),
                            if (originLatLng != null && destinationLatLng != null)
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: [originLatLng, destinationLatLng],
                                    strokeWidth: 4,
                                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7),
                                  ),
                                ],
                              ),
                            MarkerLayer(
                              markers: [
                                if (originLatLng != null)
                                  Marker(
                                    point: originLatLng,
                                    width: 36,
                                    height: 36,
                                    child: Icon(
                                      Icons.trip_origin_rounded,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 28,
                                    ),
                                  ),
                                if (destinationLatLng != null)
                                  Marker(
                                    point: destinationLatLng,
                                    width: 36,
                                    height: 36,
                                    child: Icon(
                                      Icons.flag_rounded,
                                      color: DesignTokens.statusCancelled,
                                      size: 28,
                                    ),
                                  ),
                                if (busLatLng != null)
                                  Marker(
                                    point: busLatLng,
                                    width: 44,
                                    height: 44,
                                    child: const Text('\ud83d\ude8c', style: TextStyle(fontSize: 32)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _RecentLocationsList extends StatelessWidget {
  final List<TripLocation> locations;
  const _RecentLocationsList({required this.locations});

  @override
  Widget build(BuildContext context) {
    if (locations.isEmpty) {
      return const Center(child: Text('No location reports yet.'));
    }
    return ListView.builder(
      key: const Key('tracking_list'),
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final loc = locations[index];
        return PolishedCard(
          margin: const EdgeInsets.only(bottom: DesignTokens.spaceXs),
          padding: const EdgeInsets.all(DesignTokens.spaceSm),
          child: Row(
            children: [
              Icon(Icons.location_on_rounded, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: DesignTokens.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lat: ${loc.latitude.toStringAsFixed(4)}, Lng: ${loc.longitude.toStringAsFixed(4)}'),
                    Text(
                      'Speed: ${loc.speedKmh} km/h · ${loc.recordedAt ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
