import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../routes/app_routes.dart';
import '../theme/design_tokens.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/polished_button.dart';
import '../widgets/polished_card.dart';
import '../widgets/status_badge.dart';

/// Trip Details screen with route timeline diagram and seat selection CTA.
class TripDetailScreen extends StatelessWidget {
  const TripDetailScreen({super.key});

  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekday = weekdays[local.weekday - 1];
    final month = months[local.month - 1];
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$weekday, $month ${local.day} · $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final trip = ModalRoute.of(context)?.settings.arguments as Trip?;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? DesignTokens.darkPrimary : DesignTokens.primary;

    if (trip == null) {
      return const AppScaffold(
        title: 'Trip Details',
        child: Center(child: Text('No trip details available.')),
      );
    }

    return AppScaffold(
      title: 'Trip Details',
      centerTitle: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Route Overview Card with Timeline ────────────────────────────
          PolishedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Route ${trip.routeId}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: primary,
                      ),
                    ),
                    StatusBadge(status: trip.status),
                  ],
                ),
                const SizedBox(height: DesignTokens.spaceMd),

                // Timeline Diagram
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline dots and connector line
                    Column(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 54,
                          color: primary.withValues(alpha: 0.4),
                        ),
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: DesignTokens.accent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: DesignTokens.spaceMd),

                    // Stops & Timestamps
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Origin
                          Text(
                            trip.origin,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Departure: ${_formatDateTime(trip.departureTime)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white60 : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Destination
                          Text(
                            trip.destination,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Arrival: ${_formatDateTime(trip.arrivalTime)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white60 : const Color(0xFF64748B),
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

          // ── Trip Information Card ────────────────────────────────────────
          PolishedCard(
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.payments_rounded,
                  label: 'Fare per Seat',
                  value: '${trip.pricePerSeat.toStringAsFixed(0)} ETB',
                  isHighlighted: true,
                ),
                const Divider(height: 20),
                _InfoRow(
                  icon: Icons.directions_bus_rounded,
                  label: 'Vehicle ID',
                  value: trip.vehicleId,
                ),
                const Divider(height: 20),
                _InfoRow(
                  icon: Icons.badge_rounded,
                  label: 'Driver ID',
                  value: trip.driverId,
                ),
              ],
            ),
          ),

          const Spacer(),

          // ── Action Button ────────────────────────────────────────────────
          PolishedButton(
            key: const Key('book_button'),
            label: 'Select Seat & Book',
            icon: Icons.airline_seat_recline_extra_rounded,
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
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isHighlighted;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? DesignTokens.darkPrimary : DesignTokens.primary;

    return Row(
      children: [
        Icon(icon, size: 20, color: isHighlighted ? primary : const Color(0xFF94A3B8)),
        const SizedBox(width: DesignTokens.spaceSm),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: isDark ? Colors.white70 : const Color(0xFF64748B),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
            fontSize: isHighlighted ? 16 : 14,
            color: isHighlighted ? primary : (isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }
}