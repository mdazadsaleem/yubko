import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

enum InfoKind { faqs, safety, contact, privacy, terms }

/// Simple text pages for the website's static pages (FAQs, Safety
/// Guidelines, Contact, Privacy Policy, Terms of Service).
/// Final text will be taken from the website in Phase 2.
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key, required this.kind});

  final InfoKind kind;

  String get _title => switch (kind) {
    InfoKind.faqs => 'FAQs',
    InfoKind.safety => 'Safety Guidelines',
    InfoKind.contact => 'Contact Us',
    InfoKind.privacy => 'Privacy Policy',
    InfoKind.terms => 'Terms of Service',
  };

  List<(String, String)> get _sections => switch (kind) {
    InfoKind.safety => const [
      (
        'Visit in person',
        'Confirm the address, condition and access before transferring any money.',
      ),
      (
        'Check ownership documents',
        'Ask for relevant title or allotment documents and verify them independently.',
      ),
      (
        'Keep conversations traceable',
        'Use written messages and be cautious if someone creates urgency or avoids questions.',
      ),
      (
        'Never pay in advance',
        'Do not share payment details or send money before viewing the property in person.',
      ),
    ],
    InfoKind.faqs => const [
      (
        'Is posting a property free?',
        'Yes. Every property post on GharMarkaz is 100% free.',
      ),
      (
        'Do I need an account to browse?',
        'No. You can browse freely as a guest. Sign in only to save a listing, contact an owner, or post a property.',
      ),
      (
        'How do I contact a seller?',
        'Use the Chat button on the property page, reveal the phone number, or tap Chat on WhatsApp.',
      ),
      (
        'Are listings ranked by payment?',
        'No. There are no paid featured ads or ranking boosts.',
      ),
    ],
    InfoKind.contact => const [
      ('Phone', '+92 51 889 4427'),
      ('Email', 'support@gharmark.pk'),
      (
        'About',
        "GharMarkaz is Pakistan's transparent real estate and rental marketplace. Browse as a guest, contact sellers directly, and post your listings for free.",
      ),
    ],
    InfoKind.privacy => const [
      (
        'Privacy Policy',
        'The full privacy policy text will be placed here from the website (design placeholder).',
      ),
    ],
    InfoKind.terms => const [
      (
        'Terms of Service',
        'The full terms of service text will be placed here from the website (design placeholder).',
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          _title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        children: [
          for (final (h, b) in _sections)
            Container(
              margin: const EdgeInsets.only(bottom: 11),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    h,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    b,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
