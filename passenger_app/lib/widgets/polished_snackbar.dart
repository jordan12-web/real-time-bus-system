import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

enum PolishedSnackbarType { success, error, info }

/// Shows a bottom, rounded snackbar with icon + short message.
class PolishedSnackbar {
  PolishedSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    PolishedSnackbarType type = PolishedSnackbarType.info,
    IconData? icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accent;
    final IconData resolvedIcon;

    switch (type) {
      case PolishedSnackbarType.success:
        accent = isDark ? DesignTokens.darkPrimary : DesignTokens.primary;
        resolvedIcon = icon ?? Icons.check_circle_rounded;
      case PolishedSnackbarType.error:
        accent = DesignTokens.statusCancelled;
        resolvedIcon = icon ?? Icons.error_rounded;
      case PolishedSnackbarType.info:
        accent = isDark ? DesignTokens.darkAccent : DesignTokens.accent;
        resolvedIcon = icon ?? Icons.info_rounded;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(DesignTokens.spaceMd),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusGlobal),
        ),
        backgroundColor: isDark ? DesignTokens.darkSurface : const Color(0xFF111827),
        content: Row(
          children: [
            Icon(resolvedIcon, color: accent, size: 22),
            const SizedBox(width: DesignTokens.spaceSm),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
