import 'package:flutter/material.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String tripList = '/trip-list';
  static const String tripDetail = '/trip-detail';
  static const String booking = '/booking';
  static const String payment = '/payment';
  static const String ticket = '/ticket';
  static const String tracking = '/tracking';
  static const String signup = '/signup';
  static const String myTrips = '/my-trips';

  static Future<T?> navigateToSignup<T>(BuildContext context) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      signup,
      (route) => false,
    );
  }

  static Future<T?> navigateToLogin<T>(BuildContext context) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      login,
      (route) => false,
    );
  }

  static Future<T?> navigateToTripList<T>(BuildContext context) {
    return Navigator.pushReplacementNamed<T, dynamic>(context, tripList);
  }

  static Future<T?> navigateToTripDetail<T>(
    BuildContext context,
    String tripId,
  ) {
    return Navigator.pushNamed<T>(context, tripDetail, arguments: tripId);
  }

  static Future<T?> navigateToBooking<T>(BuildContext context, String tripId) {
    return Navigator.pushNamed<T>(context, booking, arguments: tripId);
  }

  static Future<T?> navigateToPayment<T>(
    BuildContext context,
    String bookingId,
  ) {
    return Navigator.pushNamed<T>(context, payment, arguments: bookingId);
  }

  static Future<T?> navigateToTicket<T>(
    BuildContext context,
    String bookingId,
  ) {
    return Navigator.pushNamed<T>(context, ticket, arguments: bookingId);
  }

  static Future<T?> navigateToTracking<T>(BuildContext context, String tripId) {
    return Navigator.pushNamed<T>(context, tracking, arguments: tripId);
  }

  static Future<T?> navigateToMyTrips<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, myTrips);
  }
}
