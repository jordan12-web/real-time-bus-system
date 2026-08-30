import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';
import '../controllers/driver_trip_controller.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  final _routeIdController = TextEditingController(text: 'route-bdr-add-01');
  final _vehicleIdController = TextEditingController(text: 'bus-01');
  final _originController = TextEditingController(text: 'Bahir Dar');
  final _destinationController = TextEditingController(text: 'Addis Ababa');
  final _priceController = TextEditingController(text: '800');
  DateTime _departureTime = DateTime.now().add(const Duration(hours: 1));
  DateTime _arrivalTime = DateTime.now().add(const Duration(hours: 7));

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
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid price per seat.')),
      );
      return;
    }
    if (!_departureTime.isBefore(_arrivalTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Departure must be before arrival.')),
      );
      return;
    }

    final success = await ref.read(driverTripControllerProvider.notifier).createTrip(
          routeId: _routeIdController.text.trim(),
          vehicleId: _vehicleIdController.text.trim(),
          driverId: user.id,
          origin: _originController.text.trim(),
          destination: _destinationController.text.trim(),
          departureTime: _departureTime,
          arrivalTime: _arrivalTime,
          pricePerSeat: price,
        );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(driverTripControllerProvider);

    return AppScaffold(
      title: 'Create Trip',
      child: ListView(
        children: [
          // route_id and vehicle_id are free-text strings on the real
          // schema — no pre-existing Route/Vehicle records required.
          TextField(
            key: const Key('route_id_field'),
            controller: _routeIdController,
            decoration: const InputDecoration(labelText: 'Route ID (free text)'),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('vehicle_id_field'),
            controller: _vehicleIdController,
            decoration: const InputDecoration(labelText: 'Vehicle ID (free text)'),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('origin_field'),
            controller: _originController,
            decoration: const InputDecoration(labelText: 'Origin'),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('destination_field'),
            controller: _destinationController,
            decoration: const InputDecoration(labelText: 'Destination'),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('price_field'),
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Price per seat (ETB)'),
          ),
          const SizedBox(height: 12),
          ListTile(
            key: const Key('departure_time_picker'),
            title: const Text('Departure'),
            subtitle: Text(_departureTime.toLocal().toString().split('.')[0]),
            trailing: const Icon(Icons.edit_calendar),
            onTap: () => _pickDateTime(isDeparture: true),
          ),
          ListTile(
            key: const Key('arrival_time_picker'),
            title: const Text('Arrival'),
            subtitle: Text(_arrivalTime.toLocal().toString().split('.')[0]),
            trailing: const Icon(Icons.edit_calendar),
            onTap: () => _pickDateTime(isDeparture: false),
          ),
          const SizedBox(height: 20),
          if (tripState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(tripState.errorMessage!, style: const TextStyle(color: Colors.red)),
            ),
          PrimaryButton(
            buttonKey: const Key('create_trip_button'),
            text: 'Create Trip',
            isLoading: tripState.isLoading,
            onPressed: _handleCreateTrip,
          ),
        ],
      ),
    );
  }
}