import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bindings/app_binding.dart';
import 'screens/splash/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const YubkoApp());
}

class YubkoApp extends StatelessWidget {
  const YubkoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GharMarkaz',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialBinding: AppBinding(),
      home: const SplashScreen(),
    );
  }
}
