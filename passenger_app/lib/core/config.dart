import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration loaded from `.env` via flutter_dotenv.
class Config {
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';

  /// SSE stream base URL — defaults to API base for local dev.
  static String get sseUrl =>
      dotenv.env['SSE_URL'] ??
      dotenv.env['SSE_BASE_URL'] ??
      apiBaseUrl;
}
