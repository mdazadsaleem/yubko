import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/property_card.dart';
import '../chat/chats_screen.dart';
import '../info/contact_screen.dart';
import '../info/info_screen.dart';
import '../post/post_property_screen.dart';
import '../profile/profile_screen.dart';
import '../properties/properties_screen.dart';
import '../properties/property_detail_screen.dart';
import '../roommates/roommates_screen.dart';
import 'top_searches_screen.dart';
import '../saved/saved_screen.dart';

/// Main shell after login / guest: bottom navigation with
/// Home, Search, Post, Saved and Profile — like the app version
/// of the website's header.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _goTo(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeTab(onPostTap: () => _goTo(2), onSearchTap: () => _goTo(1)),
      const PropertiesScreen(isTab: true),
      const PostPropertyScreen(isTab: true),
      const SavedScreen(isTab: true),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _goTo,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Home tab — the website homepage, in the website's order:
/// hero + search card, stats, categories, newest properties,
/// popular areas, post-property steps, safety, footer.
class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    required this.onPostTap,
    required this.onSearchTap,
  });

  final VoidCallback onPostTap;
  final VoidCallback onSearchTap;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _buy = true;
  String? _city;
  String? _type;
  String? _unit;
  final _sizeController = TextEditingController();

  @override
  void dispose() {
    _sizeController.dispose();
    super.dispose();
  }

  Future<void> _pick(
    String title,
    List<String> options,
    ValueChanged<String> onPick,
  ) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final o in options)
                    ListTile(
                      title: Text(o),
                      onTap: () => Navigator.pop(context, o),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (result != null) onPick(result);
  }

  void _openProperty(Property p) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PropertyDetailScreen(property: p),
      ),
    );
  }

  void _search() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PropertiesScreen(
          initialIsRent: !_buy,
          initialCity: _city,
          initialType: _type,
          initialSizeValue: double.tryParse(_sizeController.text.trim()),
          initialUnit: _unit,
        ),
      ),
    );
  }

  Widget _sizeInput() {
    return TextField(
      controller: _sizeController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        hintText: 'Property size',
        prefixIcon: Icon(Icons.square_foot, size: 19),
      ),
    );
  }

  void _openTopSearches() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const TopSearchesScreen()));
  }

  Widget _quickNav() {
    final items = <(String, VoidCallback)>[
      (
        'Buy',
        () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const PropertiesScreen(initialIsRent: false),
          ),
        ),
      ),
      (
        'Rent',
        () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const PropertiesScreen(initialIsRent: true),
          ),
        ),
      ),
      ('Top Searches', _openTopSearches),
      (
        'Roommates',
        () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const RoommatesScreen()),
        ),
      ),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (label, onTap) in items)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: Text(label),
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
                backgroundColor: AppColors.mint,
                side: BorderSide.none,
                onPressed: onTap,
              ),
            ),
        ],
      ),
    );
  }

  Widget _footerLink(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
        ),
      ),
    );
  }

  Widget _footer(BuildContext context) {
    void open(Widget page) {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
    }

    Widget column(String title, List<(String, VoidCallback)> links) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            for (final (label, onTap) in links) _footerLink(label, onTap),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.only(top: 18),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.home_work_rounded, color: AppColors.primary, size: 22),
              SizedBox(width: 8),
              Text(
                'GharMarkaz',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 7),
          const Text(
            "Pakistan's transparent real estate and rental marketplace. Browse as a guest, contact sellers directly, and post your listings for free.",
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textMuted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              column('Quick Links', [
                (
                  'Buy',
                  () => open(const PropertiesScreen(initialIsRent: false)),
                ),
                (
                  'Rent',
                  () => open(const PropertiesScreen(initialIsRent: true)),
                ),
                ('Top Searches', _openTopSearches),
                ('Roommates', () => open(const RoommatesScreen())),
              ]),
              column('Support', [
                ('FAQs', () => open(const InfoScreen(kind: InfoKind.faqs))),
                (
                  'Safety Guidelines',
                  () => open(const InfoScreen(kind: InfoKind.safety)),
                ),
                ('Contact Us', () => open(const ContactScreen())),
                (
                  'Privacy Policy',
                  () => open(const InfoScreen(kind: InfoKind.privacy)),
                ),
                (
                  'Terms of Service',
                  () => open(const InfoScreen(kind: InfoKind.terms)),
                ),
              ]),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '© 2026 GharMarkaz. Developed for Pakistan Real Estate Market.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          const Text(
            '+92 51 889 4427  •  support@gharmark.pk',
            style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, String? value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? label,
                style: TextStyle(
                  fontSize: 13.5,
                  color: value == null ? AppColors.hint : AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 19,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(
    String eyebrow,
    String title, {
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.emeraldDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'G',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  const Text(
                    'GharMarkaz',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.primary,
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ChatsScreen(),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      textStyle: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: widget.onPostTap,
                    child: const Text('+ Post Property'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _quickNav(),
              const SizedBox(height: 16),
              // Hero + search card (website)
              const Text(
                'Find a place that feels like home.',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Explore homes, plots and commercial property across Pakistan. Browse freely, contact sellers directly, or post your property at no cost.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.mint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          for (final buy in [true, false])
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _buy = buy),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _buy == buy
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    buy ? 'Buy' : 'Rent',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: _buy == buy
                                          ? Colors.white
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _field(
                      'City',
                      _city,
                      () => _pick(
                        'Select City',
                        dummyCities,
                        (v) => setState(() => _city = v),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _field(
                      _city == null
                          ? 'Society / area — select a city first'
                          : 'Society / area',
                      null,
                      () {
                        if (_city == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Select a city first'),
                            ),
                          );
                        } else {
                          widget.onSearchTap();
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            'Property type',
                            _type,
                            () => _pick(
                              'Property Type',
                              dummyPropertyTypes,
                              (v) => setState(() => _type = v),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _field(
                            'Size unit',
                            _unit,
                            () => _pick(
                              'Area Size Unit',
                              dummySizeUnits,
                              (v) => setState(() => _unit = v),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _sizeInput(),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _search,
                      child: const Text('Search'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Stats strip (website)
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    _Stat(value: '42,800+', label: 'Live properties'),
                    _Stat(value: '18,500+', label: 'Homes to buy'),
                    _Stat(value: '9,200+', label: 'Homes to rent'),
                    _Stat(value: '100% free', label: 'Every property post'),
                  ],
                ),
              ),
              // Categories
              _sectionTitle(
                'CATEGORIES',
                'Browse by property type',
                subtitle:
                    'Explore featured property categories across major cities with instant filtering',
              ),
              Row(
                children: [
                  _CategoryCard(
                    icon: Icons.house_rounded,
                    title: 'Houses & Hostels',
                    subtitle: 'Family homes, hostels',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const PropertiesScreen(initialType: 'House'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _CategoryCard(
                    icon: Icons.apartment_rounded,
                    title: 'Apartments & Flats',
                    subtitle: 'Flats, penthouses',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PropertiesScreen(
                          initialType: 'Flat / Apartment',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _CategoryCard(
                    icon: Icons.domain_rounded,
                    title: 'Commercial & Plots',
                    subtitle: 'Shops, offices, plots',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PropertiesScreen(
                          initialType: 'Residential Plot',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Roommates banner
              InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const RoommatesScreen(),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.group_rounded, color: Colors.white, size: 26),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Find a Roommate',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Shared rooms & spaces across Pakistan',
                              style: TextStyle(
                                color: AppColors.onGreenBody,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 15,
                      ),
                    ],
                  ),
                ),
              ),
              // Recent listings
              _sectionTitle(
                'RECENT LISTINGS',
                'Newest properties',
                subtitle:
                    'Freshly added listings direct from owners and verified agents',
                actionLabel: 'View all properties',
                onAction: widget.onSearchTap,
              ),
              for (final p in dummyProperties.take(4))
                PropertyCard(property: p, onTap: () => _openProperty(p)),
              // Popular areas
              _sectionTitle(
                'POPULAR AREAS · LIVE TRENDS',
                'Popular cities and areas',
                subtitle:
                    'Discover homes and high-demand investment locations most searched across Pakistan',
              ),
              for (final a in dummyAreas)
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PropertiesScreen(initialCity: a.city),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.city,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                a.areas,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          a.count,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.emeraldDark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              // Post property steps (website)
              _sectionTitle(
                'FOR PROPERTY OWNERS',
                'Post a property for free in simple steps',
                subtitle:
                    'List your house, apartment, plot, or commercial space in minutes and connect with interested buyers directly without middleman fees.',
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: widget.onPostTap,
                child: const Text('Post Property Free'),
              ),
              const SizedBox(height: 14),
              const _StepTile(
                number: '01',
                title: 'Add the essentials',
                text:
                    'Choose Sale or Rent, select your property type, and enter key details like size, city, and asking price.',
              ),
              const _StepTile(
                number: '02',
                title: 'Upload clear photos',
                text:
                    'Showcase your property with bright photos of bedrooms, living areas, and facade to attract genuine inquiries.',
              ),
              const _StepTile(
                number: '03',
                title: 'Publish & connect directly',
                text:
                    'Go live immediately with 100% free listing. Chat and receive inquiries directly from verified buyers and tenants.',
              ),
              // Safety (website)
              _sectionTitle(
                'SAFETY & TRUST',
                'Take your time. Verify before you commit.',
                subtitle:
                    'Our recommendations to help you make informed decisions when buying or renting:',
              ),
              const _SafetyTile(
                title: 'Visit in person',
                text:
                    'Confirm the address, condition and access before transferring any money.',
              ),
              const _SafetyTile(
                title: 'Check ownership documents',
                text:
                    'Ask for relevant title or allotment documents and verify them independently.',
              ),
              const _SafetyTile(
                title: 'Keep conversations traceable',
                text:
                    'Use written messages and be cautious if someone creates urgency or avoids questions.',
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const InfoScreen(kind: InfoKind.safety),
                    ),
                  ),
                  child: const Text('Read full safety guide'),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Have a property to sell or rent?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Post your property for free and reach thousands of buyers and tenants across Pakistan.',
                      style: TextStyle(
                        color: AppColors.onGreenBody,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 13),
                    ElevatedButton(
                      onPressed: widget.onPostTap,
                      child: const Text('Post Property Free'),
                    ),
                    const SizedBox(height: 13),
                    const Row(
                      children: [
                        Icon(
                          Icons.call_outlined,
                          color: Colors.white,
                          size: 17,
                        ),
                        SizedBox(width: 7),
                        Text(
                          '+92 51 889 4427',
                          style: TextStyle(color: Colors.white, fontSize: 12.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          color: Colors.white,
                          size: 17,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'support@gharmark.pk',
                          style: TextStyle(color: Colors.white, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _footer(context),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primary, size: 26),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textMuted,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.number,
    required this.title,
    required this.text,
  });
  final String number;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              number,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Step $number of 03',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.emeraldDark,
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

class _SafetyTile extends StatelessWidget {
  const _SafetyTile({required this.title, required this.text});
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 19,
            color: AppColors.emeraldDark,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    height: 1.35,
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
