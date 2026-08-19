import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:passenger_app/main.dart';

void main() {
  testWidgets('Verification screen renders login form', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PassengerApp()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login_email')), findsOneWidget);
    expect(find.byKey(const Key('login_password')), findsOneWidget);
    expect(find.byKey(const Key('login_button')), findsOneWidget);
  });
}
