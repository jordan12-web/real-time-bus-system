import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/driver_trip_controller.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  const TripDetailScreen({super.key});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  String? _tripId;
  // Pre-filled with a point on the Bahir Dar -> Addis Ababa line, matching
  // the passenger app's demo fallback — deterministic and reliable for a
  // live demo, independent of whether GPS/location services cooperate.
  final _latController = TextEditingController(text: '10.5');
  final _lngController = TextEditingController(text: '38.0');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tripId ??= ModalRoute.of(context)?.settings.arguments as String?;
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _handleEmitLocation() async {
    if (_tripId == null) return;
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid latitude/longitude.')),
      );
      return;
    }
    await ref.read(driverTripControllerProvider.notifier).emitLocation(
          tripId: _tripId!,
          latitude: lat,
          longitude: lng,
        );
  }

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(driverTripControllerProvider);

    return AppScaffold(
      title: 'Trip Detail',
      child: ListView(
        children: [
          Text('Trip ID: ${_tripId ?? 'unknown'}'),
          const SizedBox(height: 20),
          const Text(
            'Auto-broadcast (real GPS)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            buttonKey: const Key('start_broadcast_button'),
            text: tripState.isBroadcasting ? 'Stop Broadcasting' : 'Start Broadcasting',
            onPressed: () {
              if (_tripId == null) return;
              if (tripState.isBroadcasting) {
                ref.read(driverTripControllerProvider.notifier).stopBroadcast();
              } else {
                ref.read(driverTripControllerProvider.notifier).startBroadcast(_tripId!);
              }
            },
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          const Text(
            'Manual location (reliable fallback for demos)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('latitude_field'),
            controller: _latController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            decoration: const InputDecoration(labelText: 'Latitude'),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('longitude_field'),
            controller: _lngController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            decoration: const InputDecoration(labelText: 'Longitude'),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            buttonKey: const Key('emit_location_button'),
            text: 'Emit Location',
            onPressed: _handleEmitLocation,
          ),
          if (tripState.lastLocationStatus != null) ...[
            const SizedBox(height: 12),
            Text(tripState.lastLocationStatus!, style: const TextStyle(color: Colors.green)),
          ],
          if (tripState.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(tripState.errorMessage!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
    );
  }
}