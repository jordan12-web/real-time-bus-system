import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/main.dart';
import 'package:passenger_app/routes/app_routes.dart';
import 'package:passenger_app/theme/theme_provider.dart';
import 'package:passenger_app/widgets/main_navigation_shell.dart';

void main() {
  testWidgets('the trip-list route builds after login', (tester) async {
    final themeProvider = ThemeProvider.forTesting();

    await tester.pumpWidget(PassengerApp(themeProvider: themeProvider));

    AppKeys.navigatorKey.currentState!.pushNamed(AppRoutes.tripList);
    await tester.pump();

    expect(find.byType(MainNavigationShell), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
