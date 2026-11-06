import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/property_card.dart';
import '../properties/property_detail_screen.dart';

/// Saved / Wishlist — the website's heart-saved listings.
/// Design only: starts with sample saved homes; tapping the heart
/// removes an item from this list.
class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key, this.isTab = false});

  final bool isTab;

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final List<Property> _saved = [
    dummyProperties[0],
    dummyProperties[2],
    dummyProperties[6],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: !widget.isTab,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Saved Homes',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _saved.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 52,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No saved homes yet.\nTap the heart on any property to save it here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted, height: 1.5),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              children: [
                for (final p in _saved)
                  PropertyCard(
                    property: p,
                    saved: true,
                    onSaveTap: () => setState(() => _saved.remove(p)),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PropertyDetailScreen(property: p),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
