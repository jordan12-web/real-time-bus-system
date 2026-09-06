import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controllers/auth_controller.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/trip_detail_screen.dart';
import 'theme/theme_provider.dart';

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
  } catch (_) {}

  final themeProvider = await ThemeProvider.create();

  runApp(
    ProviderScope(
      overrides: [
        themeProviderInstance.overrideWith((ref) => themeProvider),
      ],
      child: DriverApp(themeProvider: themeProvider),
    ),
  );
}

class DriverApp extends ConsumerWidget {
  const DriverApp({super.key, required this.themeProvider});

  final ThemeProvider themeProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return ListenableBuilder(
      listenable: themeProvider,
      builder: (context, _) {
        return MaterialApp(
          key: AppKeys.rootScaffold,
          navigatorKey: AppKeys.navigatorKey,
          title: 'Guzo - Driver App',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.mode,
          initialRoute: authState.isLoggedIn ? '/dashboard' : '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/trip_detail': (context) => const TripDetailScreen(),
            '/scan_qr': (context) => const QrScannerScreen(),
          },
        );
      },
    );
  }
}