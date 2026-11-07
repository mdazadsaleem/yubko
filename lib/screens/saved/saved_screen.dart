import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/catalog_controller.dart';
import '../../data/dummy_data.dart';
import '../../controllers/saved_controller.dart';
import '../../services/catalog_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/property_card.dart';
import '../properties/property_detail_screen.dart';

/// Saved / Wishlist — the website's heart-saved listings.
/// Hearts are shared with Home, Search and Property Detail
/// through the GetX SavedController, and for signed-in users
/// they sync with the API wishlist. The listings themselves
/// load live from the API so saved items resolve to real cards.
class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key, this.isTab = false});

  final bool isTab;

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final (listings, _) = await CatalogService.fetchListings(limit: 100);
      CatalogController.to.register(
        listings.map((l) => l.toProperty()).toList(),
      );
    } catch (_) {
      // Saved samples still resolve from the local cache.
    }
    if (mounted) setState(() => _loading = false);
  }

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
      body: Obx(() {
        final savedIds = SavedController.to.ids;
        final saved = <Property>[
          for (final id in savedIds)
            if (CatalogController.to.lookup(id) != null)
              CatalogController.to.lookup(id)!,
        ];
        if (saved.isEmpty && _loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (saved.isEmpty) {
          return const Center(
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
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                '${saved.length} saved properties',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final p in saved)
              PropertyCard(
                property: p,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PropertyDetailScreen(property: p),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
