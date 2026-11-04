import 'package:flutter_test/flutter_test.dart';
import 'package:yubko/main.dart';

void main() {
  testWidgets('App opens on the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const YubkoApp());

    // Login is the default tab, matching the website's /auth page.
    expect(find.text('Welcome back'), findsOneWidget);
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
