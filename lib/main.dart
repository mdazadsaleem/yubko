import 'package:flutter/material.dart';

import 'screens/splash/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const YubkoApp());
}

class YubkoApp extends StatelessWidget {
  const YubkoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GharMarkaz',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const SplashScreen(),
    );
  }
}
