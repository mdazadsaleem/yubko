import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/session_store.dart';
import '../../theme/app_theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../home/home_screen.dart';

/// Splash screen — website green with the GharMarkaz logo.
/// Restores a saved login via GET /me; otherwise opens the dashboard.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  /// Restores a saved login (if any) and verifies it with GET /me.
  /// A valid session goes straight to the app (Home tab); everyone
  /// else sees the dashboard, as designed.
  Future<void> _start() async {
    var loggedIn = false;
    try {
      if (await SessionStore.restore()) {
        final user = await AuthService.me().timeout(const Duration(seconds: 6));
        await SessionStore.updateUser(user);
        loggedIn = true;
      }
    } catch (_) {
      await SessionStore.clear();
    }
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => loggedIn ? const MainShell() : const DashboardScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: const Text(
                'G',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 46,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'GharMarkaz',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Pakistan's transparent property marketplace",
              style: TextStyle(color: AppColors.onGreenBody, fontSize: 13),
            ),
            const SizedBox(height: 30),
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                color: AppColors.emerald,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
