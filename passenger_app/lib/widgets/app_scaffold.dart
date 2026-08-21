import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/design_tokens.dart';
import '../theme/theme_provider.dart';
import 'gradient_background.dart';

/// Shared app scaffold with translucent AppBar and gradient accent line.
class AppScaffold extends ConsumerWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  /// Detail screens use left-aligned titles per design system.
  final bool centerTitle;

  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.floatingActionButton,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeProviderInstance);
    final isDark = themeNotifier.isDark;
    final barColor = isDark
        ? DesignTokens.darkBackground.withValues(alpha: 0.92)
        : DesignTokens.backgroundStart.withValues(alpha: 0.85);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: centerTitle,
          backgroundColor: barColor,
          title: Text(title),
          actions: [
            ...?actions,
            ThemeModeToggle(
              isDark: isDark,
              onToggle: () => themeNotifier.toggle(),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (isDark ? DesignTokens.darkPrimary : DesignTokens.primary)
                        .withValues(alpha: 0.8),
                    (isDark ? DesignTokens.darkAccent : DesignTokens.accent)
                        .withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceMd),
            child: child,
          ),
        ),
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
