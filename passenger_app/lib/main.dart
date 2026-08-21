import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passenger_app/screens/signup_screen.dart';

import 'routes/app_routes.dart';
import 'screens/booking_screen.dart';
import 'screens/login_screen.dart';
import 'screens/my_trips_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/ticket_screen.dart';
import 'screens/tracking_screen.dart';
import 'screens/trip_detail_screen.dart';
import 'screens/trip_list_screen.dart';

class AppKeys {
  AppKeys._();

  static const navigator = Key('app_navigator');
  static const rootScaffold = Key('app_root_scaffold');
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    
  }
  runApp(const ProviderScope(child: PassengerApp()));
}

class PassengerApp extends StatelessWidget {
  const PassengerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: AppKeys.rootScaffold,
      navigatorKey: AppKeys.navigatorKey,
      title: 'Bus Passenger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.signup,
      routes: {
        AppRoutes.signup: (context) => const SignupScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.tripList: (context) => const TripListScreen(),
        AppRoutes.tripDetail: (context) => const TripDetailScreen(),
        AppRoutes.booking: (context) => const BookingScreen(),
        AppRoutes.payment: (context) => const PaymentScreen(),
        AppRoutes.ticket: (context) => const TicketScreen(),
        AppRoutes.tracking: (context) => const TrackingScreen(),
        AppRoutes.myTrips: (context) => const MyTripsScreen(),
      },
    );
  }
}