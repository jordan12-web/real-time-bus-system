import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration loaded from `.env` via flutter_dotenv.
class Config {
  static Map<String, String> get _env {
    try {
      return dotenv.env;
    } catch (_) {
      return const {};
    }
  }

  static String get apiBaseUrl =>
      _env['API_BASE_URL'] ?? 'https://real-time-bus-system.onrender.com';

  
  static String get sseUrl =>
      _env['SSE_URL'] ?? _env['SSE_BASE_URL'] ?? apiBaseUrl;
}