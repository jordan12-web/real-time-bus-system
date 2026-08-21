import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'design_tokens.dart';

const _themePrefKey = 'theme_mode';

/// Persists and exposes light/dark theme preference.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._prefs) {
    final stored = _prefs.getString(_themePrefKey);
    if (stored == 'dark') {
      _mode = ThemeMode.dark;
    } else if (stored == 'light') {
      _mode = ThemeMode.light;
    }
  }

  final SharedPreferences _prefs;
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  ThemeData get lightTheme => DesignTokens.lightTheme();
  ThemeData get darkTheme => DesignTokens.darkTheme();

  Future<void> setDarkMode(bool enabled) async {
    _mode = enabled ? ThemeMode.dark : ThemeMode.light;
    await _prefs.setString(_themePrefKey, enabled ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> toggle() => setDarkMode(!isDark);
}

/// Riverpod provider — initialized in main after SharedPreferences loads.
final themeProviderInstance = ChangeNotifierProvider<ThemeProvider>((ref) {
  throw UnimplementedError(
    'themeProviderInstance must be overridden in ProviderScope',
  );
});

Future<ThemeProvider> createThemeProvider() async {
  final prefs = await SharedPreferences.getInstance();
  return ThemeProvider(prefs);
}
