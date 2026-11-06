import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The website's green marketing panel ("A fair property
/// marketplace" with the three checkmark points). Shown on the
/// dashboard screen — the website's /auth side panel content.
class MarketingPanel extends StatelessWidget {
  const MarketingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    const points = [
      '100% free property posting',
      'No paid featured ads or ranking boosts',
      'Contact owners by phone or WhatsApp',
    ];
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'A FAIR PROPERTY MARKETPLACE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: AppColors.mint,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Find a place that feels right.',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Browse homes across Pakistan without an account. Sign in only when you want to save a listing, contact an owner, or post your own property.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.onGreenBody,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          for (final point in points)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 19,
                    color: AppColors.emerald,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          const Text(
            'We never charge to list a property and do not sell priority placement.',
            style: TextStyle(
              fontSize: 12.5,
              fontStyle: FontStyle.italic,
              color: AppColors.onGreenMuted,
            ),
          ),
        ],
      ),
    );
  }
}
