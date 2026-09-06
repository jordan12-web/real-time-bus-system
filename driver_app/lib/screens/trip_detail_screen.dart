import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/driver_trip_controller.dart';
import '../theme/design_tokens.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/polished_button.dart';
import '../widgets/polished_card.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  const TripDetailScreen({super.key});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  String? _tripId;
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
    FocusScope.of(context).unfocus();
    if (_tripId == null) return;
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numerical latitude and longitude.')),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? DesignTokens.darkPrimary : DesignTokens.primary;
    final accent = isDark ? DesignTokens.darkAccent : DesignTokens.accent;

    return AppScaffold(
      title: 'Trip Management',
      child: ListView(
        children: [
          // Header Card with Trip ID
          PolishedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusGlobal),
                      ),
                      child: Icon(Icons.directions_bus_rounded, color: primary, size: 24),
                    ),
                    const SizedBox(width: DesignTokens.spaceSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Active Trip Details',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _tripId != null ? 'Trip #$_tripId' : 'Unknown Trip',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (tripState.isBroadcasting)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: DesignTokens.statusConfirmed.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
                          border: Border.all(color: DesignTokens.statusConfirmed.withValues(alpha: 0.5)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.sensors_rounded, size: 14, color: DesignTokens.statusConfirmed),
                            SizedBox(width: 4),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: DesignTokens.statusConfirmed,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),

          // Section 1: Auto GPS Broadcaster Card
          PolishedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.satellite_alt_rounded, color: primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Real-Time GPS Broadcast',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spaceXs),
                Text(
                  'Continuous high-accuracy location streaming to passengers tracking this bus in real time.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceMd),
                PolishedButton(
                  buttonKey: const Key('start_broadcast_button'),
                  label: tripState.isBroadcasting ? 'Stop Broadcasting' : 'Start Auto-Broadcast',
                  icon: tripState.isBroadcasting ? Icons.sensors_off_rounded : Icons.sensors_rounded,
                  variant: tripState.isBroadcasting
                      ? PolishedButtonVariant.secondary
                      : PolishedButtonVariant.primary,
                  onPressed: () {
                    if (_tripId == null) return;
                    if (tripState.isBroadcasting) {
                      ref.read(driverTripControllerProvider.notifier).stopBroadcast();
                    } else {
                      ref.read(driverTripControllerProvider.notifier).startBroadcast(_tripId!);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),

          // Section 2: Manual Location Fallback Card
          PolishedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.pin_drop_rounded, color: accent, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Manual Location Fallback',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spaceXs),
                Text(
                  'Instantly emit precise coordinates for demonstration or indoor testing without GPS dependency.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceMd),

                // Presets Quick Chips
                const Text(
                  'Demo Location Presets:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    ActionChip(
                      label: const Text('Addis (9.0192, 38.7525)', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        setState(() {
                          _latController.text = '9.0192';
                          _lngController.text = '38.7525';
                        });
                      },
                    ),
                    ActionChip(
                      label: const Text('Midway (10.5, 38.0)', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        setState(() {
                          _latController.text = '10.5';
                          _lngController.text = '38.0';
                        });
                      },
                    ),
                    ActionChip(
                      label: const Text('Bahir Dar (11.5936, 37.3908)', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        setState(() {
                          _latController.text = '11.5936';
                          _lngController.text = '37.3908';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spaceSm),

                // Latitude Field
                TextField(
                  key: const Key('latitude_field'),
                  controller: _latController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: const InputDecoration(
                    labelText: 'Latitude',
                    prefixIcon: Icon(Icons.my_location_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceSm),

                // Longitude Field
                TextField(
                  key: const Key('longitude_field'),
                  controller: _lngController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: const InputDecoration(
                    labelText: 'Longitude',
                    prefixIcon: Icon(Icons.location_searching_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceMd),

                // Emit Location Button
                PolishedButton(
                  buttonKey: const Key('emit_location_button'),
                  label: 'Emit Single Location',
                  icon: Icons.send_rounded,
                  variant: PolishedButtonVariant.primary,
                  onPressed: _handleEmitLocation,
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),

          // Status & Error Banners
          if (tripState.lastLocationStatus != null) ...[
            Container(
              padding: const EdgeInsets.all(DesignTokens.spaceSm),
              decoration: BoxDecoration(
                color: DesignTokens.statusConfirmed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusGlobal),
                border: Border.all(
                  color: DesignTokens.statusConfirmed.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: DesignTokens.statusConfirmed, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tripState.lastLocationStatus!,
                      style: const TextStyle(
                        color: DesignTokens.statusConfirmed,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.spaceSm),
          ],

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
                  Icon(Icons.error_outline_rounded, color: Theme.of(context).colorScheme.error, size: 20),
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
          const SizedBox(height: DesignTokens.spaceLg),
        ],
      ),
    );
  }
}