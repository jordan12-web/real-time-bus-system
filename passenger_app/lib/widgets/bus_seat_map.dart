import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Interactive bus cabin seat map with authentic 2+2 layout, driver cockpit, and animated seat selection.
class BusSeatMap extends StatelessWidget {
  final int totalSeats;
  final String? selectedSeat;
  final Set<String> occupiedSeats;
  final ValueChanged<String> onSeatSelected;

  const BusSeatMap({
    super.key,
    this.totalSeats = 20,
    required this.selectedSeat,
    this.occupiedSeats = const {},
    required this.onSeatSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? DesignTokens.darkPrimary : DesignTokens.primary;
    final cardBg = isDark ? const Color(0xFF131D31) : Colors.white;

    final rowsCount = (totalSeats / 4).ceil();

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(32),
          bottom: Radius.circular(DesignTokens.radiusGlobal),
        ),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: DesignTokens.cardShadow(),
      ),
      child: Column(
        children: [
          // ── Bus Front / Windshield & Cockpit ──────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceMd,
              vertical: DesignTokens.spaceSm,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primary.withValues(alpha: 0.15),
                  primary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // Windshield bar
                Container(
                  height: 6,
                  width: 80,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceSm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Driver area
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFE2E8F0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.sports_motorsports_rounded,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Driver',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    // Front entrance label
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF94A3B8),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ENTRY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Seat Rows (2 Left + Aisle + 2 Right) ─────────────────────────
          Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceMd),
            child: Column(
              children: List.generate(rowsCount, (rowIndex) {
                final seat1 = 'Seat ${rowIndex * 4 + 1}';
                final seat2 = 'Seat ${rowIndex * 4 + 2}';
                final seat3 = 'Seat ${rowIndex * 4 + 3}';
                final seat4 = 'Seat ${rowIndex * 4 + 4}';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Left pair
                      _SeatWidget(
                        seatNumber: seat1,
                        index: rowIndex * 4 + 1,
                        isSelected: selectedSeat == seat1,
                        isOccupied: occupiedSeats.contains(seat1),
                        onTap: () => onSeatSelected(seat1),
                      ),
                      const SizedBox(width: 8),
                      _SeatWidget(
                        seatNumber: seat2,
                        index: rowIndex * 4 + 2,
                        isSelected: selectedSeat == seat2,
                        isOccupied: occupiedSeats.contains(seat2),
                        onTap: () => onSeatSelected(seat2),
                      ),

                      // Central Aisle with road/walkway indicator
                      Container(
                        width: 44,
                        alignment: Alignment.center,
                        child: Text(
                          '${rowIndex + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),

                      // Right pair
                      _SeatWidget(
                        seatNumber: seat3,
                        index: rowIndex * 4 + 3,
                        isSelected: selectedSeat == seat3,
                        isOccupied: occupiedSeats.contains(seat3),
                        onTap: () => onSeatSelected(seat3),
                      ),
                      const SizedBox(width: 8),
                      _SeatWidget(
                        seatNumber: seat4,
                        index: rowIndex * 4 + 4,
                        isSelected: selectedSeat == seat4,
                        isOccupied: occupiedSeats.contains(seat4),
                        onTap: () => onSeatSelected(seat4),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // ── Seat Legend ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignTokens.spaceMd,
              0,
              DesignTokens.spaceMd,
              DesignTokens.spaceMd,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LegendItem(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderColor: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  label: 'Available',
                ),
                _LegendItem(
                  color: primary,
                  borderColor: primary,
                  label: 'Selected',
                ),
                _LegendItem(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                  borderColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                  label: 'Occupied',
                  isOccupied: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeatWidget extends StatelessWidget {
  final String seatNumber;
  final int index;
  final bool isSelected;
  final bool isOccupied;
  final VoidCallback onTap;

  const _SeatWidget({
    required this.seatNumber,
    required this.index,
    required this.isSelected,
    required this.isOccupied,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? DesignTokens.darkPrimary : DesignTokens.primary;

    final Color bgColor;
    final Color borderColor;
    final Color textColor;

    if (isOccupied) {
      bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0);
      borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1);
      textColor = isDark ? Colors.white30 : const Color(0xFF94A3B8);
    } else if (isSelected) {
      bgColor = primary;
      borderColor = primary;
      textColor = Colors.white;
    } else {
      bgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
      borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
      textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    }

    return Semantics(
      button: true,
      enabled: !isOccupied,
      selected: isSelected,
      label: '$seatNumber, ${isOccupied ? "Occupied" : isSelected ? "Selected" : "Available"}',
      child: GestureDetector(
        key: Key('seat_item_$index'),
        onTap: isOccupied ? null : onTap,
        child: AnimatedScale(
          scale: isSelected ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: isSelected ? 2 : 1.5),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top mini headrest indicator
                Container(
                  width: 20,
                  height: 3,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white54
                        : (isDark ? Colors.white24 : const Color(0xFF94A3B8)),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                const SizedBox(height: 3),
                if (isOccupied)
                  Icon(Icons.close_rounded, size: 16, color: textColor)
                else
                  Text(
                    '$index',
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 13,
                      color: textColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String label;
  final bool isOccupied;

  const _LegendItem({
    required this.color,
    required this.borderColor,
    required this.label,
    this.isOccupied = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: isOccupied
              ? const Icon(Icons.close_rounded, size: 12, color: Color(0xFF94A3B8))
              : null,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
