import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'routes/app_routes.dart';
import 'screens/booking_screen.dart';
import 'screens/login_screen.dart';
import 'screens/my_trips_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/ticket_screen.dart';
import 'screens/tracking_screen.dart';
import 'screens/trip_detail_screen.dart';
import 'screens/trip_list_screen.dart';
import 'theme/theme_provider.dart';

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
    // .env is optional in local/test runs.
  }

  final themeProvider = await createThemeProvider();

  runApp(
    ProviderScope(
      overrides: [
        themeProviderInstance.overrideWith((ref) => themeProvider),
      ],
      child: PassengerApp(themeProvider: themeProvider),
    ),
  );
}

class PassengerApp extends StatelessWidget {
  const PassengerApp({super.key, required this.themeProvider});

  final ThemeProvider themeProvider;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeProvider,
      builder: (context, _) {
        return MaterialApp(
          key: AppKeys.rootScaffold,
          navigatorKey: AppKeys.navigatorKey,
          title: 'Bus Passenger',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.mode,
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
      },
    );
  }
}
