import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';
import '../controllers/driver_trip_controller.dart';
import '../models/trip.dart';
import '../widgets/app_scaffold.dart';

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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final tripState = ref.watch(driverTripControllerProvider);

    return AppScaffold(
      title: 'My Trips',
      actions: [
        IconButton(
          key: const Key('refresh_trips_button'),
          icon: const Icon(Icons.refresh),
          onPressed: () {
            final user = authState.user;
            if (user != null) {
              ref.read(driverTripControllerProvider.notifier).loadMyTrips(user.id);
            }
          },
        ),
        IconButton(
          key: const Key('logout_button'),
          icon: const Icon(Icons.logout),
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
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  key: const Key('create_trip_button'),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Trip'),
                  onPressed: () => Navigator.of(context).pushNamed('/create_trip'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('scan_qr_button'),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan Ticket'),
                  onPressed: () => Navigator.of(context).pushNamed('/scan_qr'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (tripState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(tripState.errorMessage!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: tripState.isLoading && tripState.trips.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : tripState.trips.isEmpty
                    ? const Center(child: Text('No trips assigned to you yet.'))
                    : ListView.builder(
                        key: const Key('trip_list'),
                        itemCount: tripState.trips.length,
                        itemBuilder: (context, index) {
                          final Trip trip = tripState.trips[index];
                          return Card(
                            key: Key('trip_item_${trip.id}'),
                            child: ListTile(
                              title: Text('${trip.origin} \u2192 ${trip.destination}'),
                              subtitle: Text(
                                'Departs: ${trip.departureTime.toLocal().toString().split('.')[0]}\nStatus: ${trip.status}',
                              ),
                              isThreeLine: true,
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.of(context).pushNamed(
                                '/trip_detail',
                                arguments: trip.id,
                              ),
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