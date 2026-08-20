import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/booking_controller.dart';
import '../models/trip.dart';
import '../routes/app_routes.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  String? _selectedSeat;

  @override
  Widget build(BuildContext context) {
    final trip = ModalRoute.of(context)?.settings.arguments as Trip?;
    final bookingState = ref.watch(bookingControllerProvider);

    if (trip == null) {
      return const AppScaffold(
        title: 'Booking',
        child: Center(child: Text('Invalid trip selection.')),
      );
    }

    return AppScaffold(
      title: 'Select Seat & Confirm',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${trip.origin} → ${trip.destination}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Price: ${trip.pricePerSeat.toStringAsFixed(2)} ETB'),
            const SizedBox(height: 16),
            const Text(
              'Choose your seat:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 20,
                itemBuilder: (context, index) {
                  final seatNum = 'Seat ${index + 1}';
                  final isSelected = _selectedSeat == seatNum;
                  return InkWell(
                    key: Key('seat_item_${index + 1}'),
                    onTap: () {
                      setState(() {
                        _selectedSeat = seatNum;
                      });
                      ref
                          .read(bookingControllerProvider.notifier)
                          .selectSeat(seatNum);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.deepPurple
                            : Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Colors.deepPurple
                              : Colors.deepPurple.shade200,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.deepPurple,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (bookingState.errorMessage != null) ...[
              Text(
                bookingState.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 8),
            ],
            if (_selectedSeat != null) ...[
              Text(
                'Selected: $_selectedSeat',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),
            ],
            PrimaryButton(
              key: const Key('confirm_booking_button'),
              text: 'Confirm Booking',
              isLoading: bookingState.isLoading,
              onPressed: () async {
                final success = await ref
                    .read(bookingControllerProvider.notifier)
                    .createBooking(trip.id, seatNumber: _selectedSeat);

                if (success && mounted) {
                  final booking = ref.read(bookingControllerProvider).booking;
                  if (booking != null) {
                    AppRoutes.navigateToPayment(context, booking.id);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
