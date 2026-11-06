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
  });

  final String title;
  final String subtitle;
  final bool? isRent;
  final String? city;
  final String? type;
}

const _searches = [
  _TopSearch(
    title: 'Houses for sale in Lahore',
    subtitle: 'Family homes in DHA, Gulberg and Askari',
    isRent: false,
    city: 'Lahore',
    type: 'House',
  ),
  _TopSearch(
    title: 'Flats for rent in Karachi',
    subtitle: 'Apartments and flats for monthly rent',
    isRent: true,
    city: 'Karachi',
    type: 'Flat / Apartment',
  ),
  _TopSearch(
    title: 'Residential plots in Lahore',
    subtitle: 'Plots in DHA and developing societies',
    isRent: false,
    city: 'Lahore',
    type: 'Residential Plot',
  ),
  _TopSearch(
    title: 'Hostels in Faisalabad',
    subtitle: 'Rooms and bed spaces near universities',
    isRent: true,
    city: 'Faisalabad',
    type: 'Room / Hostel',
  ),
  _TopSearch(
    title: 'Houses for rent in Islamabad',
    subtitle: 'Homes in F and G sectors',
    isRent: true,
    city: 'Islamabad',
    type: 'House',
  ),
  _TopSearch(
    title: 'Shops for rent in Faisalabad',
    subtitle: 'Commercial spaces on busy roads',
    isRent: true,
    city: 'Faisalabad',
    type: 'Shop',
  ),
  _TopSearch(
    title: 'Apartments for sale in Karachi',
    subtitle: 'Ready-to-move flats and apartments',
    isRent: false,
    city: 'Karachi',
    type: 'Flat / Apartment',
  ),
  _TopSearch(
    title: 'Houses for sale in Faisalabad',
    subtitle: 'Homes in Eden Gardens and Canal Road areas',
    isRent: false,
    city: 'Faisalabad',
    type: 'House',
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
            'The property searches people open most often across Pakistan.',
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
