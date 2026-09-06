import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';
import '../controllers/driver_trip_controller.dart';
import '../theme/design_tokens.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/polished_button.dart';
import '../widgets/polished_card.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  // Clean initialization — NO PRE-FILLED TEST TEXTS
  final _routeIdController = TextEditingController();
  final _vehicleIdController = TextEditingController();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _priceController = TextEditingController();
  
  DateTime _departureTime = DateTime.now().add(const Duration(hours: 1));
  DateTime _arrivalTime = DateTime.now().add(const Duration(hours: 7));

  final List<String> _popularCities = const [
    'Addis Ababa',
    'Bahir Dar',
    'Hawassa',
    'Adama',
    'Gondar',
    'Dire Dawa',
    'Mekelle',
  ];

  @override
  void dispose() {
    _routeIdController.dispose();
    _vehicleIdController.dispose();
    _originController.dispose();
    _destinationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required bool isDeparture}) async {
    final initial = isDeparture ? _departureTime : _arrivalTime;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;
    final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isDeparture) {
        _departureTime = combined;
      } else {
        _arrivalTime = combined;
      }
    });
  }

  Future<void> _handleCreateTrip() async {
    FocusScope.of(context).unfocus();

    final user = ref.read(authControllerProvider).user;
    if (user == null) return;

    final routeId = _routeIdController.text.trim();
    final vehicleId = _vehicleIdController.text.trim();
    final origin = _originController.text.trim();
    final destination = _destinationController.text.trim();

    if (routeId.isEmpty || vehicleId.isEmpty || origin.isEmpty || destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required route fields.')),
      );
      return;
    }

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid price per seat in ETB.')),
      );
      return;
    }
    if (!_departureTime.isBefore(_arrivalTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Departure time must be before arrival time.')),
      );
      return;
    }

    final success = await ref.read(driverTripControllerProvider.notifier).createTrip(
          routeId: routeId,
          vehicleId: vehicleId,
          driverId: user.id,
          origin: origin,
          destination: destination,
          departureTime: _departureTime,
          arrivalTime: _arrivalTime,
          pricePerSeat: price,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip created successfully!')),
      );
      Navigator.of(context).pop();
    }
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
    final tripState = ref.watch(driverTripControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? DesignTokens.darkPrimary : DesignTokens.primary;

    return AppScaffold(
      title: 'Create New Trip',
      child: ListView(
        children: [
          // Section 1: Route & Vehicle Information Card
          PolishedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.alt_route_rounded, color: primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Route & Vehicle Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spaceMd),

                // Route ID Field
                TextField(
                  key: const Key('route_id_field'),
                  controller: _routeIdController,
                  decoration: const InputDecoration(
                    labelText: 'Route ID',
                    hintText: 'e.g. Route-101',
                    prefixIcon: Icon(Icons.route_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceSm),

                // Vehicle ID Field
                TextField(
                  key: const Key('vehicle_id_field'),
                  controller: _vehicleIdController,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle ID / Plate',
                    hintText: 'e.g. Bus-042',
                    prefixIcon: Icon(Icons.directions_bus_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceSm),

                // Origin Field
                TextField(
                  key: const Key('origin_field'),
                  controller: _originController,
                  decoration: const InputDecoration(
                    labelText: 'Origin City',
                    hintText: 'e.g. Addis Ababa',
                    prefixIcon: Icon(Icons.trip_origin_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceXs),

                // Quick city chip selector for Origin
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _popularCities.map((city) {
                    return ChoiceChip(
                      label: Text(city, style: const TextStyle(fontSize: 11)),
                      selected: _originController.text == city,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _originController.text = city);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: DesignTokens.spaceSm),

                // Destination Field
                TextField(
                  key: const Key('destination_field'),
                  controller: _destinationController,
                  decoration: const InputDecoration(
                    labelText: 'Destination City',
                    hintText: 'e.g. Bahir Dar',
                    prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceXs),

                // Quick city chip selector for Destination
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _popularCities.map((city) {
                    return ChoiceChip(
                      label: Text(city, style: const TextStyle(fontSize: 11)),
                      selected: _destinationController.text == city,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _destinationController.text = city);
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),

          // Section 2: Schedule & Pricing Card
          PolishedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, color: primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Schedule & Pricing',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spaceMd),

                // Price Field
                TextField(
                  key: const Key('price_field'),
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Price per Seat (ETB)',
                    hintText: 'e.g. 550',
                    prefixIcon: Icon(Icons.payments_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceSm),

                // Departure Time Picker Tile
                InkWell(
                  key: const Key('departure_time_picker'),
                  onTap: () => _pickDateTime(isDeparture: true),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusGlobal),
                  child: Container(
                    padding: const EdgeInsets.all(DesignTokens.spaceSm),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusGlobal),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 20, color: Colors.grey),
                        const SizedBox(width: DesignTokens.spaceSm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Departure Date & Time',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatDateTime(_departureTime),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.edit_calendar_rounded, color: primary, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceSm),

                // Arrival Time Picker Tile
                InkWell(
                  key: const Key('arrival_time_picker'),
                  onTap: () => _pickDateTime(isDeparture: false),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusGlobal),
                  child: Container(
                    padding: const EdgeInsets.all(DesignTokens.spaceSm),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusGlobal),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_available_rounded, size: 20, color: Colors.grey),
                        const SizedBox(width: DesignTokens.spaceSm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Estimated Arrival',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatDateTime(_arrivalTime),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.edit_calendar_rounded, color: primary, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spaceLg),

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
              child: Text(
                tripState.errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: DesignTokens.spaceMd),
          ],

          // Submit Button
          PolishedButton(
            buttonKey: const Key('create_trip_button'),
            label: 'Create Trip',
            icon: Icons.add_task_rounded,
            isLoading: tripState.isLoading,
            onPressed: tripState.isLoading ? null : _handleCreateTrip,
          ),
          const SizedBox(height: DesignTokens.spaceLg),
        ],
      ),
    );
  }
}