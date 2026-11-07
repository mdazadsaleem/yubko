import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/catalog_controller.dart';
import '../../data/api_listing.dart';
import '../../theme/app_theme.dart';
import '../properties/properties_screen.dart';

/// Fallback Top Searches — the website's current list, shown
/// until GET /settings/public answers (it carries the live list).
const _fallbackHrefs = <(String, String)>[
  (
    'Portions & Floors for Rent',
    '/properties?intent=rent&type=Upper Portion,Lower Portion',
  ),
  (
    'Flat / Apartment for Rent',
    '/properties?intent=rent&type=Flat / Apartment',
  ),
  (
    'Houses for Sale in Lahore',
    '/properties?intent=buy&city=Lahore&type=House',
  ),
  (
    'Houses for Sale in Islamabad',
    '/properties?intent=buy&city=Islamabad&type=House',
  ),
];

/// Top Searches — the website header's Top Searches menu. The
/// list itself is dynamic: it comes from the site's public
/// settings API, exactly like the website renders it. Each item
/// opens Properties with the matching filters applied.
class TopSearchesScreen extends StatefulWidget {
  const TopSearchesScreen({super.key});

  @override
  State<TopSearchesScreen> createState() => _TopSearchesScreenState();
}

class _TopSearchesScreenState extends State<TopSearchesScreen> {
  @override
  void initState() {
    super.initState();
    CatalogController.to.loadSettings();
  }

  void _open(TopSearchItem item) {
    final params = Uri.parse(item.href).queryParameters;
    final types = (params['type'] ?? '')
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toSet();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PropertiesScreen(
          initialIsRent: params['intent'] == null
              ? null
              : params['intent'] == 'rent',
          initialCity: params['city'],
          initialTypes: types.isEmpty ? null : types,
          initialSociety: params['society'],
        ),
      ),
    );
  }

  String _subtitle(TopSearchItem item) {
    final params = Uri.parse(item.href).queryParameters;
    final parts = <String>[
      if (params['type'] != null) params['type']!.replaceAll(',', ' · '),
      if (params['intent'] == 'rent') 'Rent',
      if (params['intent'] == 'buy') 'Buy',
      if (params['city'] != null) params['city']!,
      if (params['society'] != null) params['society']!,
    ];
    return parts.join(' · ');
  }

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
      body: Obx(() {
        final settings = CatalogController.to.settings.value;
        final items = settings?.topSearches.isNotEmpty == true
            ? settings!.topSearches
            : [
                for (final (label, href) in _fallbackHrefs)
                  TopSearchItem(label: label, href: href),
              ];
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          children: [
            const Text(
              'Most searched right now',
              style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
            ),
            const SizedBox(height: 10),
            for (final item in items)
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
                    size: 20,
                  ),
                  title: Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    _subtitle(item),
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  onTap: () => _open(item),
                ),
              ),
          ],
        );
      }),
    );
  }
}
