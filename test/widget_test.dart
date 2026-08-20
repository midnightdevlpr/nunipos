import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nunipos/main.dart';

void main() {
  testWidgets('Login screen shows sign-in form', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
  });

  testWidgets('Login validates empty fields', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });

  testWidgets('Navigates to register screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Create one'));
    await tester.pumpAndSettle();

    expect(find.text('Create account'), findsWidgets);
    expect(find.widgetWithText(TextFormField, 'Full name'), findsOneWidget);
  });
}
