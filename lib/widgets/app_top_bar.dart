import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Header used on the dashboard and auth screens: GharMarkaz logo
/// and name on the left, "Just looking? / Continue as guest" on the
/// right — same as the website. Optionally shows a back button.
class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key, required this.onGuestTap, this.showBack = false});

  final VoidCallback onGuestTap;
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
        const Text(
          'GharMarkaz',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Just looking?',
              style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
            ),
            GestureDetector(
              onTap: onGuestTap,
              child: const Text(
                'Continue as guest',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
