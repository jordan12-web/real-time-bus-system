import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'routes/app_routes.dart';
import 'screens/booking_screen.dart';
import 'screens/login_screen.dart';
import 'screens/my_trips_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/ticket_screen.dart';
import 'screens/tracking_screen.dart';
import 'screens/trip_detail_screen.dart';
import 'models/trip.dart';
import 'theme/theme_provider.dart';
import 'widgets/main_navigation_shell.dart';

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
  } catch (_) {}

  final themeProvider = await ThemeProvider.create();

  runApp(PassengerApp(themeProvider: themeProvider));
}

class PassengerApp extends StatelessWidget {
  const PassengerApp({super.key, required this.themeProvider});

  final ThemeProvider themeProvider;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [themeProviderInstance.overrideWith((ref) => themeProvider)],
      child: ListenableBuilder(
        listenable: themeProvider,
        builder: (context, _) {
          return MaterialApp(
            key: AppKeys.rootScaffold,
            navigatorKey: AppKeys.navigatorKey,
            title: 'Guzo - Bus Passenger',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.mode,
            initialRoute: AppRoutes.splash,
            routes: {
              AppRoutes.splash: (context) => const SplashScreen(),
              AppRoutes.onboarding: (context) => const OnboardingScreen(),
              AppRoutes.signup: (context) => const SignupScreen(),
              AppRoutes.login: (context) => const LoginScreen(),
              AppRoutes.tripList: (context) => const MainNavigationShell(),
              AppRoutes.booking: (context) => const BookingScreen(),
              AppRoutes.payment: (context) => const PaymentScreen(),
              AppRoutes.ticket: (context) => const TicketScreen(),
              AppRoutes.tracking: (context) => const TrackingScreen(),
              AppRoutes.myTrips: (context) => const MyTripsScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name != AppRoutes.tripDetail) return null;

              final trip = settings.arguments;
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => trip is Trip
                    ? TripDetailScreen(trip: trip)
                    : const _TripDetailsUnavailableScreen(),
              );
            },
          );
        },
      ),
    );
  }
}

class _TripDetailsUnavailableScreen extends StatelessWidget {
  const _TripDetailsUnavailableScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('No trip details are available for this selection.'),
        ),
      ),
    );
  }
}
