import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../properties/properties_screen.dart';

class _TopSearch {
  const _TopSearch({
    required this.title,
    required this.subtitle,
    this.isRent,
    this.city,
    this.type,
    this.society,
  });

  final String title;
  final String subtitle;
  final bool? isRent;
  final String? city;
  final String? type;
  final String? society;
}

const _searches = [
  _TopSearch(
    title: 'Houses For Sale in Karachi',
    subtitle: 'Houses · Buy · Karachi',
    isRent: false,
    city: 'Karachi',
    type: 'House',
  ),
  _TopSearch(
    title: 'Houses in Satellite Town',
    subtitle: 'Houses · Satellite Town',
    type: 'House',
    society: 'Satellite Town',
  ),
  _TopSearch(
    title: 'Houses In Lahore',
    subtitle: 'Houses · Lahore',
    city: 'Lahore',
    type: 'House',
  ),
  _TopSearch(
    title: 'Flats For Rent In Lahore',
    subtitle: 'Flats · Rent · Lahore',
    isRent: true,
    city: 'Lahore',
    type: 'Flat / Apartment',
  ),
];

/// Top Searches — the website navigation's popular-search entry.
/// Each shortcut opens Properties with the matching filters applied.
class TopSearchesScreen extends StatelessWidget {
  const TopSearchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Top Searches',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        children: [
          const Text(
            'Popular right now',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          const Text(
            "The website's most-opened searches.",
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          for (final search in _searches)
            Container(
              margin: const EdgeInsets.only(bottom: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.border),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.trending_up,
                  color: AppColors.emeraldDark,
                ),
                title: Text(
                  search.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  search.subtitle,
                  style: const TextStyle(fontSize: 11.5),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PropertiesScreen(
                      initialIsRent: search.isRent,
                      initialCity: search.city,
                      initialType: search.type,
                      initialSociety: search.society,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
