import 'package:flutter/material.dart';

/// Brand colours sampled from yubko.com (GharMarkaz).
/// The app UI replicates the website exactly — do not restyle.
class AppColors {
  AppColors._();

  static const Color primary = Color(
    0xFF1A4D40,
  ); // deep green (header/footer/buttons)
  static const Color primaryDark = Color(0xFF143D33);
  static const Color primaryDeep = Color(0xFF0D2A22);
  static const Color emerald = Color(0xFF10B981); // primary action buttons
  static const Color emeraldDark = Color(0xFF059669);
  static const Color mint = Color(
    0xFFE8F3F0,
  ); // badges, selected pills, tab track
  static const Color background = Color(0xFFF8FAF9);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1F2A26);
  static const Color textMuted = Color(0xFF68776F);
  static const Color border = Color(0xFFE2EAE6);
  static const Color facebook = Color(0xFF1877F2);
  static const Color error = Color(0xFFD64545);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.emerald,
    surface: AppColors.surface,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: const TextStyle(color: Color(0xFF9AA8A1), fontSize: 14),
      prefixIconColor: AppColors.textMuted,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.emerald, width: 1.6),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size.fromHeight(50),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.emerald
            : Colors.white,
      ),
      checkColor: const WidgetStatePropertyAll(Colors.white),
      side: const BorderSide(color: AppColors.border, width: 1.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
  );
}
