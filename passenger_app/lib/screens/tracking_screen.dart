import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/tracking_controller.dart';
import '../widgets/app_scaffold.dart';

/// Tracking Screen showing recent locations and live SSE tracking subscription.
class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  String? _tripId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_tripId == null) {
      _tripId = ModalRoute.of(context)?.settings.arguments as String?;
      if (_tripId != null) {
        Future.microtask(() {
          ref.read(trackingControllerProvider.notifier).loadRecentLocations(_tripId!);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(trackingControllerProvider);

    return AppScaffold(
      title: 'Live Tracking',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  key: const Key('tracking_subscribe_button'),
                  onPressed: trackingState.isStreaming || _tripId == null
                      ? null
                      : () {
                          ref
                              .read(trackingControllerProvider.notifier)
                              .subscribeLiveTracking(_tripId!);
                        },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Subscribe'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('tracking_unsubscribe_button'),
                  onPressed: !trackingState.isStreaming
                      ? null
                      : () {
                          ref
                              .read(trackingControllerProvider.notifier)
                              .unsubscribeLiveTracking();
                        },
                  icon: const Icon(Icons.stop),
                  label: const Text('Unsubscribe'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (trackingState.isStreaming)
            const Row(
              children: [
                Icon(Icons.sensors, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Streaming live updates...',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          const SizedBox(height: 12),
          if (trackingState.latestLocation != null)
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Latest Location',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Lat: ${trackingState.latestLocation!.latitude.toStringAsFixed(6)}, '
                      'Lng: ${trackingState.latestLocation!.longitude.toStringAsFixed(6)}',
                    ),
                    Text('Speed: ${trackingState.latestLocation!.speedKmh} km/h'),
                    if (trackingState.latestLocation!.recordedAt != null)
                      Text('Time: ${trackingState.latestLocation!.recordedAt}'),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          if (trackingState.errorMessage != null) ...[
            Text(
              trackingState.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 12),
          ],
          Expanded(
            child: trackingState.isLoading && trackingState.recentLocations.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    key: const Key('tracking_list'),
                    itemCount: trackingState.recentLocations.length,
                    itemBuilder: (context, index) {
                      final loc = trackingState.recentLocations[index];
                      return ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(
                          'Lat: ${loc.latitude.toStringAsFixed(4)}, Lng: ${loc.longitude.toStringAsFixed(4)}',
                        ),
                        subtitle: Text(
                          'Speed: ${loc.speedKmh} km/h | Recorded: ${loc.recordedAt ?? 'N/A'}',
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
