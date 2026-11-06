import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Header used on the dashboard and auth screens: back button
/// (optional), GharMarkaz logo and name. "Continue as guest" used
/// to live here — it overflowed on narrow screens, so it now sits
/// as a button on the auth screen itself.
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
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: const Text(
            'G',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Flexible(
          child: Text(
            'GharMarkaz',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
