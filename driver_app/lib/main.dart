import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controllers/auth_controller.dart';
import 'screens/create_trip_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/trip_detail_screen.dart';

class AppKeys {
  AppKeys._();

  static const navigator = Key('app_navigator');
  static const rootScaffold = Key('app_root_scaffold');
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    
    
  }
  runApp(const ProviderScope(child: DriverApp()));
}

class DriverApp extends ConsumerWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return MaterialApp(
      key: AppKeys.rootScaffold,
      navigatorKey: AppKeys.navigatorKey,
      title: 'Driver App',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      initialRoute: authState.isLoggedIn ? '/dashboard' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/create_trip': (context) => const CreateTripScreen(),
        '/trip_detail': (context) => const TripDetailScreen(),
        '/scan_qr': (context) => const QrScannerScreen(),
      },
    );
  }
}