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

    expect(find.text('Registration'), findsOneWidget);
    expect(find.text('Your email address'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
  });

  testWidgets('Registration step 1 advances to step 2 with the entered email',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Create one'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'admin@example.com');
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();

    expect(find.text("Let's set your personal account"), findsOneWidget);
    expect(find.widgetWithText(TextField, 'admin@example.com'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('Registration step 2 flags empty passwords on next', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Create one'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'admin@example.com');
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pump();

    expect(find.byIcon(Icons.warning_rounded), findsNWidgets(2));
  });

  testWidgets('Registration step 2 advances to step 3 with matching passwords',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Create one'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'admin@example.com');
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();

    final step2Fields = find.byType(TextField);
    await tester.enterText(step2Fields.at(3), 'password123');
    await tester.enterText(step2Fields.at(4), 'password123');
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();

    expect(find.text('Price display'), findsOneWidget);
    expect(find.text('After tax'), findsOneWidget);
    expect(find.text('Before tax'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);

    await tester.ensureVisible(find.text('Before tax'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Before tax'));
    await tester.pump();
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('Registration step 2 password fields show reveal toggle and live match status',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Create one'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'admin@example.com');
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.visibility_outlined), findsNWidgets(2));

    final step2Fields = find.byType(TextField);
    final passwordField = step2Fields.at(3);
    final confirmField = step2Fields.at(4);

    await tester.enterText(passwordField, 'password123');
    await tester.enterText(confirmField, 'different');
    await tester.pump();
    expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsNothing);

    await tester.enterText(confirmField, 'password123');
    await tester.pump();
    expect(find.byIcon(Icons.warning_rounded), findsNothing);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    await tester.ensureVisible(find.byIcon(Icons.visibility_outlined).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.visibility_outlined).first);
    await tester.pump();

    final revealedPasswordField = tester.widget<TextField>(passwordField);
    expect(revealedPasswordField.obscureText, isFalse);
  });
}
