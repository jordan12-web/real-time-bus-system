import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:passenger_app/controllers/auth_controller.dart';
import 'package:passenger_app/repositories/auth_repository.dart';
import 'package:passenger_app/screens/login_screen.dart';
import 'package:passenger_app/theme/theme_provider.dart';

// TODO: Define mock implementations for AuthRepository and AuthController
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    // TODO: Stub initial repository state/methods for mock tests
    when(() => mockAuthRepository.getAccessToken()).thenAnswer((_) async => null);
  });

  testWidgets('LoginScreen renders email field, password field, and login button',
      (WidgetTester tester) async {
    final themeProvider = ThemeProvider.forTesting();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          themeProviderInstance.overrideWith((ref) => themeProvider),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Verify key UI elements exist
    expect(find.byKey(const Key('login_email')), findsOneWidget);
    expect(find.byKey(const Key('login_password')), findsOneWidget);
    expect(find.byKey(const Key('login_button')), findsOneWidget);
  });

  testWidgets('Triggers login action on button press when form is valid',
      (WidgetTester tester) async {
    // TODO: Stub login repository call
    // when(() => mockAuthRepository.login(email: 'test@example.com', password: 'password'))
    //     .thenAnswer((_) async => const User(id: '1', email: 'test@example.com', name: 'Test User'));

    final themeProvider = ThemeProvider.forTesting();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          themeProviderInstance.overrideWith((ref) => themeProvider),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('login_email')), 'test@example.com');
    await tester.enterText(find.byKey(const Key('login_password')), 'password123');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pump();

    // TODO: Verify interaction with authControllerProvider / authRepositoryProvider
  });
}
