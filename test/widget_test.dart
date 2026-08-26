import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nunipos/main.dart';
import 'package:nunipos/models/product_colors.dart';
import 'package:nunipos/screens/home_screen.dart';
import 'package:nunipos/services/auth_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Login screen shows sign-in form', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Login to your account'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Sign in'), findsOneWidget);
  });

  testWidgets('Login sign-in button stays disabled until both fields are filled',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    OutlinedButton signInButton() => tester.widget<OutlinedButton>(
          find.widgetWithText(OutlinedButton, 'Sign in'),
        );

    expect(signInButton().onPressed, isNull);

    await tester.enterText(find.byType(TextFormField).first, 'admin@example.com');
    await tester.pump();
    expect(signInButton().onPressed, isNull);

    await tester.enterText(find.byType(TextFormField).last, 'password123');
    await tester.pump();
    expect(signInButton().onPressed, isNotNull);
  });

  testWidgets('Navigates to register screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Sign up now!'));
    await tester.pumpAndSettle();

    expect(find.text('Registration'), findsOneWidget);
    expect(find.text('Your email address'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
  });

  testWidgets('Registration step 1 advances to step 2 with the entered email',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Sign up now!'));
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

    await tester.tap(find.text('Sign up now!'));
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

    await tester.tap(find.text('Sign up now!'));
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

    await tester.tap(find.text('Sign up now!'));
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

  testWidgets('Completing the registration wizard creates the account and reaches home',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Sign up now!'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'admin@example.com');
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();

    final step2Fields = find.byType(TextField);
    await tester.enterText(step2Fields.at(0), 'John');
    await tester.enterText(step2Fields.at(1), 'Doe');
    await tester.enterText(step2Fields.at(3), 'password123');
    await tester.enterText(step2Fields.at(4), 'password123');
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();

    expect(find.text('Price display'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();

    expect(find.text('Choose Layout'), findsOneWidget);
    expect(find.text('Standard'), findsOneWidget);
    expect(find.text('Visual'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();

    expect(find.text('Onboarding completed'), findsOneWidget);
    await tester.tap(find.text('Close & Continue'));
    await tester.pumpAndSettle();

    expect(find.text('No items'), findsOneWidget);
    expect(find.text('Dola Oil 5 litres'), findsOneWidget);
  });

  group('Dashboard', () {
    Future<void> pumpDashboard(WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    }

    testWidgets('adding a product shows it in the cart and updates the total', (tester) async {
      await pumpDashboard(tester);

      final productCard = find.widgetWithText(InkWell, 'Dola Oil 5 litres');

      expect(find.text('No items'), findsOneWidget);

      await tester.tap(productCard);
      await tester.pump();

      expect(find.text('No items'), findsNothing);
      expect(find.text('1x 5,120.00'), findsOneWidget);
      expect(find.text('5,120.00'), findsWidgets);

      await tester.tap(productCard);
      await tester.pump();

      expect(find.text('2x 5,120.00'), findsOneWidget);
      expect(find.text('10,240.00'), findsWidgets);
    });

    testWidgets('removing a cart line empties the cart', (tester) async {
      await pumpDashboard(tester);

      await tester.tap(find.text('Dola Oil 5 litres'));
      await tester.pump();
      expect(find.text('No items'), findsNothing);

      await tester.tap(find.byIcon(Icons.close).last);
      await tester.pump();

      expect(find.text('No items'), findsOneWidget);
    });

    testWidgets('void order clears the cart', (tester) async {
      await pumpDashboard(tester);

      await tester.tap(find.text('Dola Oil 5 litres'));
      await tester.pump();
      expect(find.text('No items'), findsNothing);

      await tester.tap(find.text('Void order'));
      await tester.pump();

      expect(find.text('No items'), findsOneWidget);
    });

    testWidgets('searching filters the product grid', (tester) async {
      await pumpDashboard(tester);

      await tester.enterText(find.byType(TextField), 'nonexistent product');
      await tester.pump();

      expect(find.text('Dola Oil 5 litres'), findsNothing);
      expect(find.text('No products found'), findsOneWidget);
    });

    testWidgets('search icon opens the search screen and adding a result adds it to cart',
        (tester) async {
      await pumpDashboard(tester);

      await tester.tap(find.byIcon(Icons.search).first);
      await tester.pumpAndSettle();

      expect(find.text('Select a product to see details'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Search'), 'dola');
      await tester.pump();

      expect(find.text('Dola Oil 5 litres'), findsOneWidget);
      await tester.tap(find.text('Dola Oil 5 litres'));
      await tester.pump();

      expect(find.text('Price:'), findsOneWidget);
      expect(find.text('5,120.00'), findsOneWidget);
      expect(find.text('Quantity on hand: 1 Litres'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'OK'));
      await tester.pumpAndSettle();

      expect(find.text('No items'), findsNothing);
      expect(find.text('1x 5,120.00'), findsOneWidget);
    });

    testWidgets('search screen cancel does not add anything to the cart', (tester) async {
      await pumpDashboard(tester);

      await tester.tap(find.byIcon(Icons.search).first);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('No items'), findsOneWidget);
    });

    testWidgets('New sale walks through order name and service type, updating the toolbar',
        (tester) async {
      await pumpDashboard(tester);

      expect(find.text('Dine-in'), findsOneWidget);

      await tester.tap(find.text('New sale'));
      await tester.pumpAndSettle();

      expect(find.text('Order or customer name'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Table 5');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Service type'), findsOneWidget);
      await tester.tap(find.text('Takeaway'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Table 5'), findsOneWidget);
      expect(find.text('Takeaway'), findsOneWidget);
      expect(find.text('Dine-in'), findsNothing);
    });

    testWidgets('New sale cancelled on the order name step leaves the dashboard unchanged',
        (tester) async {
      await pumpDashboard(tester);

      await tester.tap(find.widgetWithText(InkWell, 'Dola Oil 5 litres'));
      await tester.pump();
      expect(find.text('No items'), findsNothing);

      await tester.tap(find.text('New sale'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Dine-in'), findsOneWidget);
      expect(find.text('No items'), findsNothing);
    });

    testWidgets('Tapping the service type toolbar button changes it directly', (tester) async {
      await pumpDashboard(tester);

      await tester.ensureVisible(find.text('Dine-in'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dine-in'));
      await tester.pumpAndSettle();

      expect(find.text('Service type'), findsOneWidget);
      await tester.tap(find.text('Takeaway'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Takeaway'), findsOneWidget);
      expect(find.text('Dine-in'), findsNothing);
    });

    testWidgets('Customer search shows Walk-in customer selected by default', (tester) async {
      await pumpDashboard(tester);

      await tester.ensureVisible(find.text('Customer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Customer'));
      await tester.pumpAndSettle();

      expect(find.text('Search customer'), findsOneWidget);
      expect(find.text('Walk-in customer'), findsWidgets);
      expect(find.text('Address:'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'OK'));
      await tester.pumpAndSettle();

      expect(find.text('Customer'), findsOneWidget);
    });

    testWidgets('Clearing selected customer disables OK and shows not-selected state',
        (tester) async {
      await pumpDashboard(tester);

      await tester.ensureVisible(find.text('Customer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Customer'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(OutlinedButton, 'Clear selected customer'));
      await tester.pumpAndSettle();

      expect(find.text('Customer not selected'), findsOneWidget);
      final okButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'OK'));
      expect(okButton.onPressed, isNull);
    });

    testWidgets('Adding a new customer requires a name then attaches it to the sale',
        (tester) async {
      await pumpDashboard(tester);

      await tester.ensureVisible(find.text('Customer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Customer'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Add new customer'));
      await tester.pumpAndSettle();

      expect(find.text('New customer'), findsOneWidget);
      final okBefore = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'OK'));
      expect(okBefore.onPressed, isNull);

      await tester.enterText(find.byType(TextField).first, 'Jane Doe');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'OK'));
      await tester.pumpAndSettle();

      expect(find.text('Jane Doe'), findsWidgets);
      await tester.tap(find.widgetWithText(ElevatedButton, 'OK'));
      await tester.pumpAndSettle();

      expect(find.text('Jane Doe'), findsOneWidget);
    });

    testWidgets('Transfer moves quantity to the destination order and updates the cart',
        (tester) async {
      await pumpDashboard(tester);

      await tester.tap(find.widgetWithText(InkWell, 'Dola Oil 5 litres'));
      await tester.pump();
      expect(find.text('1x 5,120.00'), findsOneWidget);

      await tester.tap(find.text('Transfer'));
      await tester.pumpAndSettle();

      expect(find.text('Transfer (1)'), findsOneWidget);
      final okBefore = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'OK'));
      expect(okBefore.onPressed, isNull);

      await tester.tap(find.text('Dola Oil 5 litres'));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      expect(find.text('Dola Oil 5 litres'), findsOneWidget);

      await tester.tap(find.text('Select order'));
      await tester.pumpAndSettle();

      expect(find.text('Open orders'), findsOneWidget);
      expect(find.text('No open orders'), findsOneWidget);
      await tester.tap(find.widgetWithText(OutlinedButton, 'New sale'));
      await tester.pumpAndSettle();

      final okAfter = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'OK'));
      expect(okAfter.onPressed, isNotNull);

      await tester.tap(find.widgetWithText(ElevatedButton, 'OK'));
      await tester.pumpAndSettle();

      expect(find.text('No items'), findsOneWidget);
      expect(find.text('Transferred to order #1.'), findsOneWidget);
    });

    testWidgets('Cancelling transfer leaves the cart unchanged', (tester) async {
      await pumpDashboard(tester);

      await tester.tap(find.widgetWithText(InkWell, 'Dola Oil 5 litres'));
      await tester.pump();

      await tester.tap(find.text('Transfer'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('1x 5,120.00'), findsOneWidget);
    });

    testWidgets('Save sale parks the order and it appears in the Open orders list',
        (tester) async {
      await pumpDashboard(tester);

      await tester.tap(find.widgetWithText(InkWell, 'Dola Oil 5 litres'));
      await tester.pump();

      await tester.ensureVisible(find.text('Save sale'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save sale'));
      await tester.pump();

      expect(find.text('Order #1 saved.'), findsOneWidget);
      expect(find.text('No items'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.widgetWithText(InkWell, 'Dola Oil 5 litres'));
      await tester.pump();
      await tester.ensureVisible(find.text('Transfer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Transfer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select order'));
      await tester.pumpAndSettle();

      expect(find.text('Open orders'), findsOneWidget);
      expect(find.text('5,120.00'), findsOneWidget);
      expect(find.text('Dine-in'), findsOneWidget);
    });

    testWidgets('Transfer User re-authenticates with the current password', (tester) async {
      AuthService.instance.register(
        name: 'Jane Cashier',
        email: 'jane.cashier@example.com',
        password: 'secret123',
      );
      await pumpDashboard(tester);

      await tester.tap(find.widgetWithText(InkWell, 'Dola Oil 5 litres'));
      await tester.pump();
      await tester.ensureVisible(find.text('Transfer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Transfer'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('User'));
      await tester.pumpAndSettle();

      expect(find.text('Password'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'wrong');
      await tester.tap(find.widgetWithText(ElevatedButton, 'OK'));
      await tester.pump();
      expect(find.text('Incorrect password.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'secret123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'OK'));
      await tester.pumpAndSettle();

      expect(find.text('Jane Cashier'), findsOneWidget);
    });

    testWidgets('Transfer rounds selects a whole round at once', (tester) async {
      await pumpDashboard(tester);

      await tester.tap(find.widgetWithText(InkWell, 'Dola Oil 5 litres'));
      await tester.pump();
      await tester.ensureVisible(find.text('Transfer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Transfer'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Transfer rounds'));
      await tester.pumpAndSettle();

      expect(find.text('Select rounds to transfer'), findsOneWidget);
      expect(find.text('#1 (5,120.00)'), findsOneWidget);

      await tester.tap(find.text('Select none'));
      await tester.pump();
      var okButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'OK'));
      expect(okButton.onPressed, isNull);

      await tester.tap(find.text('Select all'));
      await tester.pump();
      okButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'OK'));
      expect(okButton.onPressed, isNotNull);

      await tester.tap(find.widgetWithText(ElevatedButton, 'OK'));
      await tester.pumpAndSettle();

      expect(find.text('Dola Oil 5 litres'), findsOneWidget);
      final transferOkButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'OK'));
      expect(transferOkButton.onPressed, isNull);
    });

    testWidgets(
        'Cart discount below cost price shows a warning and applies once confirmed',
        (tester) async {
      await pumpDashboard(tester);

      final productCard = find.widgetWithText(InkWell, 'Dola Oil 5 litres');
      await tester.tap(productCard);
      await tester.pump();
      await tester.tap(productCard);
      await tester.pump();
      expect(find.text('2x 5,120.00'), findsOneWidget);

      await tester.tap(find.text('Discount'));
      await tester.pumpAndSettle();

      expect(find.text('Apply cart discount'), findsOneWidget);
      await tester.ensureVisible(find.text('3'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.ensureVisible(find.byIcon(Icons.keyboard_return));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.keyboard_return));
      await tester.pumpAndSettle();

      expect(find.text('Invalid price'), findsOneWidget);
      expect(
        find.textContaining('Dola Oil 5 litres'),
        findsWidgets,
      );

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      expect(find.text('10,240.00'), findsNWidgets(2));
      expect(find.text('9,932.80'), findsNWidgets(2));
    });

    testWidgets('Refund walks through receipt entry and receipt-delivery options',
        (tester) async {
      await pumpDashboard(tester);

      await tester.tap(find.widgetWithText(InkWell, 'Dola Oil 5 litres'));
      await tester.pump();

      await tester.ensureVisible(find.text('Refund'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Refund'));
      await tester.pumpAndSettle();

      expect(find.text('Refund items'), findsOneWidget);
      expect(find.text('TOTAL REFUND AMOUNT'), findsOneWidget);
      expect(find.text('-5,120.00'), findsOneWidget);

      final okButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'OK'));
      expect(okButton.onPressed, isNull);

      await tester.enterText(find.byType(TextField), '1001');
      await tester.pump();
      await tester.tap(find.text('CARD'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'OK'));
      await tester.pumpAndSettle();

      expect(find.text('Actions'), findsOneWidget);
      expect(find.text('Refund: '), findsOneWidget);
      expect(find.text('Card:'), findsOneWidget);

      await tester.ensureVisible(find.text('Send email'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send email'));
      await tester.pump();
      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Done'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Done'));
      await tester.pumpAndSettle();

      expect(find.text('No items'), findsOneWidget);
      expect(find.text('Refund completed.'), findsOneWidget);
    });

    testWidgets('Search mode toggle changes the hint text and what is matched',
        (tester) async {
      await pumpDashboard(tester);

      expect(find.text('Search products by name, code or barcode'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.qr_code_scanner));
      await tester.pump();
      expect(find.text('Search products by barcode'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Dola');
      await tester.pump();
      expect(find.text('Dola Oil 5 litres'), findsNothing);

      await tester.enterText(find.byType(TextField), '0000000001');
      await tester.pump();
      expect(find.text('Dola Oil 5 litres'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.tag));
      await tester.pump();
      expect(find.text('Search products by code'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '0000000001');
      await tester.pump();
      expect(find.text('Dola Oil 5 litres'), findsNothing);

      await tester.enterText(find.byType(TextField), '5l');
      await tester.pump();
      expect(find.text('Dola Oil 5 litres'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.sell_outlined));
      await tester.pump();
      expect(find.text('Search products by name'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '0000000001');
      await tester.pump();
      expect(find.text('Dola Oil 5 litres'), findsNothing);

      await tester.enterText(find.byType(TextField), 'Dola');
      await tester.pump();
      expect(find.text('Dola Oil 5 litres'), findsOneWidget);
    });

    testWidgets('Side menu opens with all items and placeholders show coming soon',
        (tester) async {
      await pumpDashboard(tester);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('POS - NuniPOS'), findsOneWidget);
      expect(find.text('Management'), findsOneWidget);
      expect(find.text('View sales history'), findsOneWidget);
      expect(find.text('View open sales'), findsOneWidget);
      expect(find.text('Cash In / Out'), findsOneWidget);
      expect(find.text('Credit payments'), findsOneWidget);

      await tester.tap(find.text('View sales history'));
      await tester.pump();
      expect(find.text('View sales history coming soon.'), findsOneWidget);

      await tester.dragUntilVisible(
        find.text('Feedback'),
        find.byType(ListView),
        const Offset(0, -100),
      );
      expect(find.text('End of day'), findsOneWidget);
      expect(find.text('User info'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
      expect(find.text('Feedback'), findsOneWidget);
    });

    testWidgets('Side menu sign out returns to the login screen', (tester) async {
      await pumpDashboard(tester);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.dragUntilVisible(
        find.text('Sign out'),
        find.byType(ListView),
        const Offset(0, -100),
      );
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(find.text('Login to your account'), findsOneWidget);
    });

    testWidgets('Management opens with its sidebar and a real dashboard page',
        (tester) async {
      await pumpDashboard(tester);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Management'));
      await tester.pumpAndSettle();

      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('Products'), findsOneWidget);
      await tester.dragUntilVisible(
        find.text('My company'),
        find.byType(ListView),
        const Offset(0, -100),
      );
      expect(find.text('My company'), findsOneWidget);
      expect(find.textContaining('Monthly Sales'), findsOneWidget);
      expect(find.text('Total Sales'), findsOneWidget);
      expect(find.text('No data to display'), findsWidgets);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('No items'), findsOneWidget);
    });

    testWidgets('Management Products lets you add, edit, and delete a product',
        (tester) async {
      await pumpDashboard(tester);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Management'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();

      expect(find.text('Products count: 1'), findsOneWidget);
      expect(find.text('Dola Oil 5 litres'), findsOneWidget);

      await tester.ensureVisible(find.widgetWithText(InkWell, 'New product'));
      await tester.tap(find.widgetWithText(InkWell, 'New product'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('product_name_field')), 'Test Mop');
      await tester.pump();
      expect(
        tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Save')).onPressed,
        isNotNull,
        reason: 'Save should be enabled once a name is entered',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.text('Products count: 2'), findsOneWidget);
      expect(find.text('Test Mop'), findsOneWidget);

      await tester.tap(find.widgetWithText(InkWell, 'Test Mop'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.ensureVisible(find.widgetWithText(InkWell, 'Edit product'));
      await tester.tap(find.widgetWithText(InkWell, 'Edit product'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('product_name_field')), 'Test Mop XL');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.text('Test Mop'), findsNothing);
      expect(find.text('Test Mop XL'), findsOneWidget);

      await tester.tap(find.widgetWithText(InkWell, 'Test Mop XL'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.ensureVisible(find.widgetWithText(InkWell, 'Delete product'));
      await tester.tap(find.widgetWithText(InkWell, 'Delete product'));
      await tester.pumpAndSettle();

      expect(find.text('Delete "Test Mop XL"? This cannot be undone.'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Products count: 1'), findsOneWidget);
      expect(find.text('Test Mop XL'), findsNothing);
      expect(find.text('Dola Oil 5 litres'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(InkWell, 'Dola Oil 5 litres'), findsOneWidget);
    });

    testWidgets('Management Products color picker saves and reopens the selected color',
        (tester) async {
      await pumpDashboard(tester);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Management'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.widgetWithText(InkWell, 'New product'));
      await tester.tap(find.widgetWithText(InkWell, 'New product'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('product_name_field')), 'Color Test');
      await tester.pump();

      await tester.ensureVisible(find.text('Image & color'));
      await tester.tap(find.text('Image & color'));
      await tester.pumpAndSettle();

      expect(find.text('Transparent'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_drop_down));
      await tester.pumpAndSettle();

      // The menu opens scrolled to the current value ('Transparent'), so pick
      // a color alphabetically next to it rather than one from the far end
      // of the (virtualized, 150-entry) list.
      expect(find.text('Turquoise'), findsOneWidget);
      await tester.tap(find.text('Turquoise'));
      await tester.pumpAndSettle();

      expect(find.text('Turquoise'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.text('Products count: 2'), findsOneWidget);

      await tester.tap(find.widgetWithText(InkWell, 'Color Test'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.ensureVisible(find.widgetWithText(InkWell, 'Edit product'));
      await tester.tap(find.widgetWithText(InkWell, 'Edit product'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Image & color'));
      await tester.tap(find.text('Image & color'));
      await tester.pumpAndSettle();

      expect(find.text('Turquoise'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      final cardContainer = tester.widget<Container>(
        find.descendant(
          of: find.widgetWithText(InkWell, 'Color Test'),
          matching: find.byType(Container),
        ),
      );
      final decoration = cardContainer.decoration as BoxDecoration;
      expect(decoration.color, productColors['Turquoise']);
    });

    testWidgets('Management Products print opens a printer selection dialog',
        (tester) async {
      await pumpDashboard(tester);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Management'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.widgetWithText(InkWell, 'Print'));
      await tester.tap(find.widgetWithText(InkWell, 'Print'));
      await tester.pumpAndSettle();

      expect(find.text('Printer'), findsOneWidget);
      expect(find.text('Microsoft Print to PDF'), findsOneWidget);
      expect(find.text('Page range'), findsOneWidget);
      expect(find.text('Copies'), findsOneWidget);

      await tester.tap(find.text('Current page'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Print'));
      await tester.pumpAndSettle();

      expect(find.text('Printer'), findsNothing);
      expect(find.textContaining('coming soon'), findsOneWidget);
    });

    testWidgets('Management Stock shows inventory totals and filters by quantity status',
        (tester) async {
      await pumpDashboard(tester);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Management'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Stock'));
      await tester.pumpAndSettle();

      expect(find.text('Dola Oil 5 litres'), findsOneWidget);
      expect(find.text('Negative quantity'), findsOneWidget);
      expect(find.text('Active products'), findsOneWidget);
      expect(find.text('Total cost:'), findsOneWidget);
      expect(find.text('5,120.00'), findsWidgets);

      final negativeSwitch = find.descendant(
        of: find.widgetWithText(Row, 'Negative quantity').first,
        matching: find.byType(Switch),
      );
      await tester.tap(negativeSwitch);
      await tester.pumpAndSettle();

      expect(find.text('Dola Oil 5 litres'), findsNothing);
      expect(find.text('No products to display'), findsOneWidget);

      await tester.tap(negativeSwitch);
      await tester.pumpAndSettle();

      expect(find.text('Dola Oil 5 litres'), findsOneWidget);
    });

    testWidgets('Management Promotions shows the empty state and a coming-soon create flow',
        (tester) async {
      await pumpDashboard(tester);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Management'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Promotions'));
      await tester.pumpAndSettle();

      expect(find.text('No promotions'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      final editButton = tester.widget<InkWell>(find.widgetWithText(InkWell, 'Edit'));
      final deleteButton = tester.widget<InkWell>(find.widgetWithText(InkWell, 'Delete'));
      expect(editButton.onTap, isNull);
      expect(deleteButton.onTap, isNull);

      await tester.tap(find.text('Create new promotion'));
      await tester.pump();

      expect(find.textContaining('coming soon'), findsOneWidget);
    });

    testWidgets('Management Users & security lists the signed-in account as Owner',
        (tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.text('Sign up now!'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'owner@example.com');
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();

      final step2Fields = find.byType(TextField);
      await tester.enterText(step2Fields.at(0), 'Jane');
      await tester.enterText(step2Fields.at(1), 'Smith');
      await tester.enterText(step2Fields.at(3), 'password123');
      await tester.enterText(step2Fields.at(4), 'password123');
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();

      expect(find.text('Onboarding completed'), findsOneWidget);
      await tester.tap(find.text('Close & Continue'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Management'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Users & security'));
      await tester.pumpAndSettle();

      expect(find.text('Users'), findsWidgets);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('First name'), findsOneWidget);
      expect(find.text('Jane'), findsOneWidget);
      expect(find.text('Smith'), findsOneWidget);
      expect(find.text('owner@example.com'), findsOneWidget);
      expect(find.text('Owner'), findsOneWidget);

      await tester.ensureVisible(find.text('Security'));
      await tester.tap(find.text('Security'));
      await tester.pumpAndSettle();

      expect(find.text('Security coming soon.'), findsOneWidget);
    });
  });
}
