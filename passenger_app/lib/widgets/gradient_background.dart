import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Full-screen gradient background wrapper used by main screens.
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: DesignTokens.backgroundGradient(isDark: isDark),
      ),
      child: child,
    );
  }
}

/// Toggle for persisted dark mode — reusable in AppBar actions.
class ThemeModeToggle extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const ThemeModeToggle({
    super.key,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      button: true,
      child: IconButton(
        key: const Key('theme_mode_toggle'),
        icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
        tooltip: isDark ? 'Light mode' : 'Dark mode',
        onPressed: onToggle,
      ),
    );
  }
}
