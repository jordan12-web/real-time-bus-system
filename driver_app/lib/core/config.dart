import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  Config._();

  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://real-time-bus-system.onrender.com';
}


class ApiEndpoints {
  ApiEndpoints._();

  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String trips = '/trips'; // POST to create, GET to list (role: driver/admin for POST)
  static const String trackingReport = '/tracking/report'; // role: driver/admin
  static const String ticketValidate = '/tickets/validate'; // role: driver/admin
}