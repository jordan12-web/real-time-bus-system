import 'package:flutter/material.dart';

/// Modern Gradient design system tokens.
abstract final class DesignTokens {
  // ── Brand colors (light) ──────────────────────────────────────────────
  static const Color primary = Color(0xFF10B981);
  static const Color accent = Color(0xFF6366F1);
  static const Color backgroundStart = Color(0xFFF0FDF4);
  static const Color backgroundEnd = Color(0xFFECFDF5);

  // ── Brand colors (dark) ───────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkSurface = Color(0xFF151D2E);
  static const Color darkPrimary = Color(0xFF0FBF9A);
  static const Color darkAccent = Color(0xFF7C7BFF);

  // ── Status badge colors ───────────────────────────────────────────────
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusConfirmed = Color(0xFF10B981);
  static const Color statusCancelled = Color(0xFFEF4444);

  // ── Spacing (8px base grid) ───────────────────────────────────────────
  static const double spaceXs = 8;
  static const double spaceSm = 12;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;

  // ── Radii ─────────────────────────────────────────────────────────────
  static const double radiusGlobal = 12;
  static const double radiusPill = 24;
  static const double buttonHeight = 48;

  // ── Shadows ───────────────────────────────────────────────────────────
  static List<BoxShadow> cardShadow({bool pressed = false}) => [
        BoxShadow(
          color: Color.fromRGBO(16, 24, 40, pressed ? 0.12 : 0.06),
          offset: Offset(0, pressed ? 8 : 4),
          blurRadius: pressed ? 20 : 12,
        ),
      ];

  // ── Motion ────────────────────────────────────────────────────────────
  static const Duration microInteraction = Duration(milliseconds: 100);
  static const Duration pageTransition = Duration(milliseconds: 280);
  static const Curve easing = Cubic(0.2, 0.8, 0.2, 1);

  /// Inter when available; falls back to platform sans-serif.
  static const String fontFamily = 'Inter';
  static const List<String> fontFamilyFallback = [
    'Segoe UI',
    'Roboto',
    'Helvetica Neue',
    'Arial',
    'sans-serif',
  ];

  static TextStyle _styled({
    required double fontSize,
    required FontWeight fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // ── Typography ────────────────────────────────────────────────────────
  static TextTheme textTheme({required Brightness brightness}) {
    final color = brightness == Brightness.dark ? Colors.white : const Color(0xFF111827);
    return TextTheme(
      headlineSmall: _styled(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: color),
      titleMedium: _styled(fontSize: 16, fontWeight: FontWeight.w600, color: color),
      bodyMedium: _styled(fontSize: 14, fontWeight: FontWeight.w400, height: 1.4, color: color),
      labelLarge: _styled(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1, color: color),
    );
  }

  static LinearGradient backgroundGradient({required bool isDark}) {
    if (isDark) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0B1220), Color(0xFF111827)],
      );
    }
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [backgroundStart, backgroundEnd],
    );
  }

  static ThemeData lightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: accent,
      surface: Colors.white,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundStart,
      textTheme: textTheme(brightness: Brightness.light),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: backgroundStart.withValues(alpha: 0.85),
        foregroundColor: const Color(0xFF111827),
        titleTextStyle: _styled(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF111827),
        ),
        iconTheme: const IconThemeData(size: 24),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusGlobal),
        ),
        margin: EdgeInsets.zero,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusGlobal),
        ),
        backgroundColor: const Color(0xFF111827),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusGlobal),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceMd,
          vertical: spaceSm,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData darkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: darkPrimary,
      primary: darkPrimary,
      secondary: darkAccent,
      surface: darkSurface,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackground,
      textTheme: textTheme(brightness: Brightness.dark),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: darkBackground.withValues(alpha: 0.92),
        foregroundColor: Colors.white,
        titleTextStyle: _styled(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(size: 24),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusGlobal),
        ),
        margin: EdgeInsets.zero,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusGlobal),
        ),
        backgroundColor: darkSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusGlobal),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceMd,
          vertical: spaceSm,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
