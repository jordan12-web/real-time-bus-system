import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/auth_controller.dart' show tripRepositoryProvider;
import '../controllers/tracking_controller.dart';
import '../core/city_coordinates.dart';
import '../models/trip.dart';
import '../models/trip_location.dart';
import '../widgets/app_scaffold.dart';

/// Live Tracking screen: OpenStreetMap view (via flutter_map, no API key
/// needed) showing the origin/destination as pins with a route line between
/// them, and the bus's live position from SSE tracking data as a moving
/// marker. Falls back gracefully (no pins/line, bus marker only) if the
/// trip's origin/destination text isn't in our known-cities lookup.
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

  /// Haversine-based ETA: straight-line distance from the bus's current
  /// position to the destination, divided by its last reported speed. This
  /// is a rough estimate (not routed along roads) — good enough for a demo.
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

    return AppScaffold(
      title: _trip != null ? '${_trip!.origin} \u2192 ${_trip!.destination}' : 'Live Tracking',
      actions: [
        IconButton(
          key: const Key('toggle_tracking_list_button'),
          icon: Icon(_showList ? Icons.map : Icons.list),
          tooltip: _showList ? 'Show map' : 'Show list',
          onPressed: () => setState(() => _showList = !_showList),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (trackingState.isStreaming)
                const Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.sensors, color: Colors.green, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Live',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              else
                const Expanded(
                  child: Text('Waiting for driver location...', style: TextStyle(color: Colors.grey)),
                ),
              if (eta != null)
                Chip(
                  avatar: const Icon(Icons.schedule, size: 16),
                  label: Text('ETA: $eta'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (trackingState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                trackingState.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: _showList
                ? _RecentLocationsList(locations: trackingState.recentLocations)
                : _loadingTrip && busLatLng == null
                    ? const Center(child: CircularProgressIndicator())
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
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
                                    color: Colors.blueAccent.withValues(alpha: 0.7),
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
                                    child: const Icon(Icons.trip_origin, color: Colors.green, size: 28),
                                  ),
                                if (destinationLatLng != null)
                                  Marker(
                                    point: destinationLatLng,
                                    width: 36,
                                    height: 36,
                                    child: const Icon(Icons.flag, color: Colors.red, size: 28),
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
        return ListTile(
          leading: const Icon(Icons.location_on),
          title: Text('Lat: ${loc.latitude.toStringAsFixed(4)}, Lng: ${loc.longitude.toStringAsFixed(4)}'),
          subtitle: Text('Speed: ${loc.speedKmh} km/h | Recorded: ${loc.recordedAt ?? 'N/A'}'),
        );
      },
    );
  }
}