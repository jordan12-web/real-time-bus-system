import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'design_tokens.dart';

const _themePrefKey = 'theme_mode';

/// Persists and exposes light/dark theme preference.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider._(this._storage, this._mode, this._initialized);

  final FlutterSecureStorage _storage;
  ThemeMode _mode;
  bool _initialized;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;
  bool get isInitialized => _initialized;

  ThemeData get lightTheme => DesignTokens.lightTheme();
  ThemeData get darkTheme => DesignTokens.darkTheme();

  /// Production bootstrap — reads persisted preference before first frame.
  static Future<ThemeProvider> create() async {
    const storage = FlutterSecureStorage();
    var mode = ThemeMode.light;
    try {
      final stored = await storage.read(key: _themePrefKey);
      if (stored == 'dark') mode = ThemeMode.dark;
    } catch (_) {
      // Non-fatal — default to light mode.
    }
    return ThemeProvider._(storage, mode, true);
  }

  /// Test bootstrap — skips secure storage I/O.
  factory ThemeProvider.forTesting({ThemeMode mode = ThemeMode.light}) {
    return ThemeProvider._(const FlutterSecureStorage(), mode, true);
  }

  Future<void> setDarkMode(bool enabled) async {
    _mode = enabled ? ThemeMode.dark : ThemeMode.light;
    try {
      await _storage.write(key: _themePrefKey, value: enabled ? 'dark' : 'light');
    } catch (_) {
      // Persist best-effort; in-memory mode still applies this session.
    }
    notifyListeners();
  }

  Future<void> toggle() => setDarkMode(!isDark);
}

/// Riverpod provider — initialized in main after ThemeProvider.create().
final themeProviderInstance = ChangeNotifierProvider<ThemeProvider>((ref) {
  throw UnimplementedError(
    'themeProviderInstance must be overridden in ProviderScope',
  );
});
