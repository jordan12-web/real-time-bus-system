import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../routes/app_routes.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';

class TripDetailScreen extends StatelessWidget {
  const TripDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trip = ModalRoute.of(context)?.settings.arguments as Trip?;

    if (trip == null) {
      return const AppScaffold(
        title: 'Trip Details',
        child: Center(child: Text('No trip details available.')),
      );
    }

    return AppScaffold(
      title: 'Trip Details',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${trip.origin} → ${trip.destination}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _DetailRow(icon: Icons.schedule, label: 'Departure', value: trip.departureTime.toLocal().toString().split('.')[0]),
                    const Divider(),
                    _DetailRow(icon: Icons.event, label: 'Arrival', value: trip.arrivalTime.toLocal().toString().split('.')[0]),
                    const Divider(),
                    _DetailRow(icon: Icons.payments, label: 'Price per Seat', value: '${trip.pricePerSeat.toStringAsFixed(2)} ETB'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            PrimaryButton(
              key: const Key('book_button'),
              text: 'Select Seat & Book',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.booking,
                  arguments: trip,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.black87)),
      ],
    );
  }
}