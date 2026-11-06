import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/marketing_panel.dart';
import '../auth/auth_screen.dart';

/// Dashboard (first) screen of the app: the website's green
/// marketing panel, kept exactly as designed. The Next button
/// moves to the Login / Sign Up screen. There is no guest option
/// on this screen (user, 2026-11-06) — "Continue as guest" lives
/// on the Login / Sign Up screen only.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppTopBar(),
              const SizedBox(height: 18),
              const MarketingPanel(),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Next'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 19),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '© 2026 GharMarkaz. Developed for Pakistan Real Estate Market.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
