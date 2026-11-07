import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

enum InfoKind { faqs, safety, contact, privacy, terms }

class _Section {
  const _Section(this.title, {this.body, this.bullets = const []});
  final String title;
  final String? body;
  final List<String> bullets;
}

/// Static pages with the website's own content (checked on
/// yubko.com 2026-11-06): FAQs, Safety Guidelines, Privacy Policy
/// and Terms of Service. Contact has its own screen with the
/// website's message form.
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

  String? get _intro => switch (kind) {
    InfoKind.faqs =>
      'Everything you need to know about GharMark — posting, safety, rules, and our no-fee promise.',
    InfoKind.safety =>
      '#1 Rule: Never pay in advance. Never send token money, advance rent, or "booking" fees before visiting the property and verifying ownership. GharMark never asks for payments on behalf of owners.',
    InfoKind.privacy =>
      'Our Privacy Commitment: We never sell or lease your telephone numbers or personal emails to commercial telemarketers. Information is collected solely to power your property search, connect you with verified sellers, and prevent marketplace fraud.',
    InfoKind.terms =>
      'Platform Notice: GharMark is an online communications and listing marketplace. We are not real estate brokers, auctioneers, or escrow agents. We do not own, inspect, or hold title deeds to listed properties. Buyers and renters must verify title documents independently before disbursing funds.',
    _ => null,
  };

  List<_Section> get _sections => switch (kind) {
    InfoKind.safety => const [
      _Section(
        '1. Guidelines for Buyers & Renters — What You Should Do',
        bullets: [
          'Visit in Daylight: Schedule property visits during daytime hours and bring a family member or trusted acquaintance.',
          "Verify Original Title Deeds: Check the original Registry, Fard Malkiyat, or Housing Society Allotment letter (CDA, LDA, DHA, RDA, KDA) matching the seller's CNIC.",
          'Pay Traceably: Issue payments via crossed bank cheques or pay orders with signed, witnessed receipts. Avoid cash handovers.',
          'Inspect Utility Bills: Check electricity, gas, and water bills for outstanding dues or meter disputes.',
        ],
      ),
      _Section(
        'Red Flags to Avoid',
        bullets: [
          'Artificial Urgency: Claims like "another buyer is paying now, send 20,000 PKR token right now to hold it."',
          'Unrealistically Low Prices: Luxury properties listed at half market value are usually bait-and-switch or fake listings.',
          'Refusal to Meet: Sellers who refuse to meet in person or claim they are "out of city/country" and request wire transfer.',
          'Unregistered Agents: Agents unwilling to provide office addresses or verifiable credentials.',
        ],
      ),
      _Section(
        '2. Guidelines for Sellers & Landlords',
        body:
            'Ensure fair listings and protect your home during physical viewings.',
        bullets: [
          'Verify Prospective Visitors: When showing an occupied residential home, ask for visitor identification and avoid scheduling late-night visits.',
          'Accurate Listing Specifications: Clearly state genuine Marla/Kanal size, true monthly rent or demand, and active utilities (gas, water, electricity).',
          'Formal Tenancy Registration: Complete legal rent agreements on non-judicial stamp paper and register tenant verification with local police stations as required by law.',
          'Promptly Archive Closed Deals: Mark properties as Sold or Rented as soon as an agreement is finalized to avoid unnecessary calls.',
        ],
      ),
      _Section(
        '3. Roommate Finder Precautions',
        bullets: [
          'Meet in Public First: Arrange your initial meeting at a public coffee shop or university cafeteria, not in a private room alone.',
          'Verify ID & Background: Exchange student IDs or workplace references to establish mutual trust and accountability.',
          'Document Cost Splitting: Agree in advance in writing on utility bill splits, guest hours, and deposit refund terms.',
        ],
      ),
      _Section(
        '4. Zero Tolerance for Fraud',
        body:
            "GharMark actively monitors listings for misleading information, duplicate posts, and abusive behavior. Confirmed advance payment scams result in immediate account deletion, telephone blacklisting, and referral to the FIA Cyber Crime Wing under Pakistan's PECA law.",
      ),
    ],
    InfoKind.faqs => const [
      _Section(
        'Is GharMark 100% free to use?',
        body:
            'Yes! GharMark provides free property listings for individual homeowners, tenants, and authorized real estate agents across Pakistan. You can upload photos, describe your property, set your price in PKR, and receive direct buyer inquiries without any upfront listing fees or mandatory commissions. Revenue comes only from certified services and optional add-ons, never from priority placement.',
      ),
      _Section(
        'Can I browse properties without creating an account?',
        body:
            'Yes. You can browse freely as a guest. Sign in only to save a listing, contact an owner, or post a property.',
      ),
      _Section(
        'How do I contact a property owner?',
        body:
            "After signing in, use the Reveal owner's number button or WhatsApp on the listing page.",
      ),
      _Section(
        'How long does it take for my listing to go live?',
        body:
            'Standard listings go live immediately. Automated safety filters scan for spam, fraud and misinformation first, so a flagged listing may take a few hours for manual review.',
      ),
      _Section(
        'Do you charge any fees to post a property?',
        body: 'No. There are no posting or browsing fees.',
      ),
      _Section(
        'What should I do before paying token money or rent?',
        body:
            'Never pay in advance. Physically verify the property and the ownership documents first, and contact support if you are unsure.',
      ),
      _Section(
        "Can I post a listing if I don't own the property?",
        body:
            'Only with written authorization from the owner or legal possession of the property. Buyers should verify the authorisation.',
      ),
      _Section(
        'How does GharMark verify listings?',
        body:
            'GharMark does not verify property ownership. Verified badges and OCR scans help screen fraudulent ads, but users must take responsibility and check documents themselves.',
      ),
      _Section(
        'How do I report a scam or a fake listing?',
        body:
            'Use the Report this listing button on any property page. The support team reviews reports within 24 hours.',
      ),
    ],
    InfoKind.contact => const [
      _Section('Helpline', body: '+92 51 889 4427'),
      _Section(
        'Email',
        body: 'support@yubko.com — replies typically within 2–4 hours.',
      ),
    ],
    InfoKind.privacy => const [
      _Section(
        '1. Information We Collect',
        body:
            'We collect information necessary to facilitate property transactions and maintain platform security:',
        bullets: [
          'Account Information: Name, email address, password hash, and optional profile image.',
          'Contact Details: Verified Pakistani mobile telephone number (+92) for buyer-seller communication and OTP login.',
          'Listing Data: City, sector, address, property specifications (Marla/Kanal/SqFt, bedrooms, bathrooms), pricing in PKR, and uploaded photos.',
          'Technical Data: Device browser, IP address, and essential session cookies for authentication.',
        ],
      ),
      _Section(
        '2. How We Use Your Data',
        body:
            'Your data is used strictly for legitimate marketplace functions:',
        bullets: [
          'To display your property advertisements to prospective buyers and tenants.',
          'To enable direct contact via phone, WhatsApp, or in-app messaging.',
          'To detect and prevent duplicate listings, fake pricing (e.g., PKR 1), and fraudulent advance token requests.',
          'To provide customer support and notify you about inquiries on your properties.',
        ],
      ),
      _Section(
        '3. Phone Number & Contact Privacy',
        body:
            'When you post a property on GharMark, your contact phone number is made visible to interested buyers to allow direct calls and WhatsApp messages. We deploy automated rate-limiting to protect seller numbers from automated web scrapers.',
      ),
      _Section(
        '4. Data Security & Storage',
        body:
            'We apply standard technical safeguards to protect your personal information:',
        bullets: [
          'All web traffic is encrypted in transit using SSL/TLS encryption.',
          'Passwords are securely hashed using bcrypt and are never stored in plain text.',
          'Data is stored in high-security cloud databases with restricted engineering access.',
        ],
      ),
      _Section(
        '5. Third-Party Services & Legal Compliance',
        body:
            'We share limited technical data only with cloud infrastructure providers (e.g., image hosting) and authentication partners (Google OAuth). We comply with all applicable laws of Pakistan, including the Prevention of Electronic Crimes Act (PECA 2016), and only disclose records when legally compelled by court orders.',
      ),
      _Section(
        '6. Your Rights & Account Deletion',
        body:
            'You retain full control over your data. You can edit your profile, archive listings, or request complete account deletion at any time by contacting our support team at privacy@gharmark.pk.',
      ),
    ],
    InfoKind.terms => const [
      _Section(
        '1. Acceptance & Eligibility',
        body:
            'By accessing GharMark, registering an account, or posting listings, you agree to comply with these Terms of Service and all applicable laws of Pakistan. You must be at least 18 years old to create an account or publish advertisements on the platform.',
      ),
      _Section(
        '2. Listing & Content Standards',
        body: 'When creating property or roommate listings, you agree to:',
        bullets: [
          'Only market properties you own or hold written legal authorization to advertise.',
          'Provide accurate area measurements (Marla, Kanal, Square Feet) and truthful utility availability.',
          'Use genuine, actual photographs of the property. Misleading stock photos or copyrighted images are strictly prohibited.',
          'Avoid submitting duplicate listings for the same property unit across multiple categories or areas.',
        ],
      ),
      _Section(
        '3. Accurate Pricing in PKR',
        body:
            'All listed demands and monthly rents must represent the genuine expected transaction value in Pakistani Rupees (PKR). Entering placeholder values (such as "PKR 1") to manipulate search ranking is a violation of these terms and results in listing removal.',
      ),
      _Section(
        '4. Roommate Finder Conduct',
        body:
            'Users of the Roommate Finder agree to honest representations of living habits, rent sharing, and respect for privacy. Discrimination, harassment, or non-consensual sharing of personal contact information will result in immediate and permanent account suspension.',
      ),
      _Section(
        '5. Prohibited Activities & Fraud',
        body:
            'The following activities are strictly prohibited and may result in legal referral:',
        bullets: [
          'Requesting advance token money, bayana, or security deposits online before in-person property inspection.',
          'Automated scraping or mass harvesting of user phone numbers and listing data.',
          'Advertising illegal land, unapproved schemes, or encroached plots.',
          'Transmitting unsolicited commercial messages or spam via in-app chat.',
        ],
      ),
      _Section(
        '6. Limitation of Liability',
        body:
            'GharMark is provided on an "AS IS" basis. We do not guarantee the accuracy of third-party advertisements. In no event shall GharMark be held liable for monetary losses, private token money disputes, or contractual defaults between buyers, tenants, and sellers.',
      ),
      _Section(
        '7. Governing Law & Jurisdiction',
        body:
            'These Terms are governed by and construed under the laws of the Islamic Republic of Pakistan. Any legal proceedings arising from your use of the platform shall be settled exclusively in the competent courts of Islamabad / Rawalpindi, Pakistan.',
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
          if (kind == InfoKind.safety ||
              kind == InfoKind.privacy ||
              kind == InfoKind.terms)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                kind == InfoKind.safety
                    ? 'Last reviewed: October 2026'
                    : 'Last updated: October 2026',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          if (_intro != null)
            Container(
              margin: const EdgeInsets.only(bottom: 11),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _intro!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          for (final section in _sections)
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
                    section.title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
                  if (section.body != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      section.body!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                  for (final bullet in section.bullets)
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.check_circle,
                              size: 15,
                              color: AppColors.emeraldDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              bullet,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textPrimary,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              '+92 51 889 4427  •  support@yubko.com',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
