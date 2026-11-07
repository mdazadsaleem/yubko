import 'package:flutter/material.dart';

import '../config/site_assets.dart';
import '../theme/app_theme.dart';

/// Header used on the dashboard and auth screens: back button
/// (optional) and the website's Yubko logo. "Continue as guest"
/// used to live here — it overflowed on narrow screens, so it now
/// sits as a button on the auth screen itself.
class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key, this.showBack = false});

  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack)
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        if (showBack) const SizedBox(width: 10),
        // The website's Yubko logo (static site picture).
        Image.network(
          SiteAssets.logo,
          height: 32,
          errorBuilder: (_, _, _) => const Text(
            'yubko',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
