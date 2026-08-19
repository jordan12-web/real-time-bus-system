import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';
import '../controllers/trip_controller.dart';
import '../routes/app_routes.dart';
import '../widgets/app_scaffold.dart';

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

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(tripControllerProvider);

    return AppScaffold(
      title: 'Available Bus Trips',
      actions: [
        IconButton(
          key: const Key('logout_button'),
          icon: const Icon(Icons.logout),
          tooltip: 'Log out',
          onPressed: () async {
            final navigator = Navigator.of(context);
            await ref.read(authControllerProvider.notifier).logout();
            navigator.pushReplacementNamed(AppRoutes.login);
          },
        ),
      ],
      child: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    key: const Key('search_origin_input'),
                    controller: _originController,
                    decoration: const InputDecoration(
                      labelText: 'Origin (e.g. Addis Ababa)',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    key: const Key('search_destination_input'),
                    controller: _destinationController,
                    decoration: const InputDecoration(
                      labelText: 'Destination (e.g. Hawassa)',
                      prefixIcon: Icon(Icons.flag_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      key: const Key('search_button'),
                      onPressed: _onSearch,
                      icon: const Icon(Icons.search),
                      label: const Text('Search Trips'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: tripState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : tripState.errorMessage != null
                    ? Center(
                        child: Text(
                          tripState.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : tripState.trips.isEmpty
                        ? const Center(child: Text('No trips found for selected route.'))
                        : ListView.builder(
                            key: const Key('trip_list'),
                            itemCount: tripState.trips.length,
                            itemBuilder: (context, index) {
                              final trip = tripState.trips[index];
                              return Card(
                                key: Key('trip_item_${trip.id}'),
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: ListTile(
                                  title: Text(
                                    '${trip.origin} → ${trip.destination}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    'Departure: ${trip.departureTime.toLocal().toString().split('.')[0]}\nRoute: ${trip.routeId}',
                                  ),
                                  trailing: Text(
                                    '${trip.pricePerSeat.toStringAsFixed(2)} ETB',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.tripDetail,
                                      arguments: trip,
                                    );
                                  },
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
