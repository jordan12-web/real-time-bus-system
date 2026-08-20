import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/my_bookings_controller.dart';
import '../models/booking.dart';
import '../routes/app_routes.dart';
import '../widgets/app_scaffold.dart';

class MyTripsScreen extends ConsumerStatefulWidget {
  const MyTripsScreen({super.key});

  @override
  ConsumerState<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends ConsumerState<MyTripsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(myBookingsControllerProvider.notifier).loadMyBookings();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'expired':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myBookingsControllerProvider);

    return AppScaffold(
      title: 'My Trips',
      actions: [
        IconButton(
          key: const Key('refresh_my_trips_button'),
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
          onPressed: () {
            ref.read(myBookingsControllerProvider.notifier).loadMyBookings();
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          if (state.isLoading && state.bookings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorMessage != null && state.bookings.isEmpty) {
            return Center(
              child: Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (state.bookings.isEmpty) {
            return const Center(
              child: Text('You have no bookings yet — go book a trip!'),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(myBookingsControllerProvider.notifier).loadMyBookings(),
            child: ListView.builder(
              key: const Key('my_trips_list'),
              itemCount: state.bookings.length,
              itemBuilder: (context, index) {
                final Booking booking = state.bookings[index];
                return Card(
                  key: Key('my_trip_item_${booking.id}'),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Booking',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Chip(
                              label: Text(
                                booking.status,
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: _statusColor(booking.status),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                        if (booking.seatNumber != null)
                          Text('Seat: ${booking.seatNumber}'),
                        Text(
                          '${booking.totalAmount.toStringAsFixed(2)} ${booking.currency}',
                        ),
                        const SizedBox(height: 8),
                        if (booking.status == 'pending')
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton(
                              key: Key('pay_now_${booking.id}'),
                              onPressed: () {
                                AppRoutes.navigateToPayment(context, booking.id);
                              },
                              child: const Text('Pay Now'),
                            ),
                          ),
                        if (booking.status == 'confirmed')
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton(
                              key: Key('view_ticket_${booking.id}'),
                              onPressed: () {
                                AppRoutes.navigateToTicket(context, booking.id);
                              },
                              child: const Text('View Ticket'),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}