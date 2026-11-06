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
    expect(find.text('Create a free account'), findsOneWidget);

    // Switching to Sign Up shows the registration form.
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Join GharMarkaz'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
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
}
