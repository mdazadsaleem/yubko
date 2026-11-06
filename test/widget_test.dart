import 'package:flutter_test/flutter_test.dart';
import 'package:yubko/main.dart';

void main() {
  testWidgets('Dashboard opens first, Next goes to login screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const YubkoApp());

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
}
