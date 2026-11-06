import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yubko/main.dart';

void main() {
  testWidgets('Splash -> dashboard -> Next -> login/signup form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const YubkoApp());

    // Splash shows first, then the dashboard.
    expect(find.text('GharMarkaz'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1800));

    // Dashboard: marketing panel + guest option + Next button.
    expect(find.text('Find a place that feels right.'), findsOneWidget);
    expect(find.text('Continue as guest'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    // Next moves to the Login / Sign Up screen.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Continue as guest'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with Facebook'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);

    // Switching to Sign Up shows the registration form.
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Full name *'), findsOneWidget);
    expect(find.text('Mobile number *'), findsOneWidget);
    expect(find.text('City *'), findsOneWidget);
    expect(find.text('WhatsApp number (optional)'), findsOneWidget);
    expect(find.text('Bio / dealer info (optional)'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('Guest from dashboard opens the app home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const YubkoApp());
    await tester.pump(const Duration(milliseconds: 1800));

    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();

    // Main shell with the website homepage content + bottom nav.
    expect(find.text('Find a place that feels like home.'), findsOneWidget);
    expect(find.text('Browse by property type'), findsOneWidget);
    expect(find.text('Search'), findsWidgets);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
  testWidgets('Top Searches and full property filters are present', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const YubkoApp());
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();

    expect(find.text('Top Searches'), findsWidgets);
    expect(find.text('Have a property to sell or rent?'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();

    expect(find.text('Society / Area'), findsOneWidget);
    expect(find.text('Minimum Price'), findsOneWidget);
    expect(find.text('Maximum Price'), findsOneWidget);
    expect(find.text('Property Size'), findsOneWidget);
    expect(find.text('Amenities'), findsOneWidget);
  });

  testWidgets('Roommates filters and post form are present', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const YubkoApp());
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Roommates').first);
    await tester.pumpAndSettle();

    expect(
      find.text('Available Roommates & Spaces across Pakistan'),
      findsOneWidget,
    );
    expect(find.text('Gender Preference'), findsOneWidget);
    expect(find.text('Non-smoker only'), findsOneWidget);
    expect(find.text('Sort by'), findsOneWidget);

    await tester.tap(find.text('+ Post Roommate Ad'));
    await tester.pumpAndSettle();

    expect(find.text('Your Name'), findsOneWidget);
    expect(find.text('Room Type'), findsOneWidget);
    expect(find.text('Monthly Budget (PKR)'), findsOneWidget);
  });
}
