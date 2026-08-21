import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Pill-shaped status badge with semantic color mapping.
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color _backgroundFor(String value) {
    switch (value.toLowerCase()) {
      case 'confirmed':
      case 'success':
      case 'scheduled':
        return DesignTokens.statusConfirmed;
      case 'pending':
        return DesignTokens.statusPending;
      case 'cancelled':
      case 'expired':
      case 'failed':
        return DesignTokens.statusCancelled;
      default:
        return DesignTokens.accent;
    }
  }

  String _labelFor(String value) {
    if (value.isEmpty) return 'Unknown';
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final bg = _backgroundFor(status);
    return Semantics(
      label: 'Status: ${_labelFor(status)}',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceSm,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: bg.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
          border: Border.all(color: bg.withValues(alpha: 0.5)),
        ),
        child: Text(
          _labelFor(status),
          style: TextStyle(
            color: bg,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
