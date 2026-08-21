import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:passenger_app/main.dart';
import 'package:passenger_app/theme/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App boots with Modern Gradient theme wired', (tester) async {
    final themeProvider = ThemeProvider.forTesting();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themeProviderInstance.overrideWith((ref) => themeProvider),
        ],
        child: PassengerApp(themeProvider: themeProvider),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(AppKeys.rootScaffold), findsOneWidget);
    expect(find.byKey(const Key('theme_mode_toggle')), findsOneWidget);
  });
}
