import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/property_card.dart';
import 'filters_screen.dart';
import 'property_detail_screen.dart';

enum PropertySort { newest, priceLow, priceHigh }

/// Properties (search results) screen — the website's /properties
/// page: purpose/city summary, Filters, sort, result cards.
class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({
    super.key,
    this.isTab = false,
    this.initialIsRent,
    this.initialCity,
    this.initialType,
  });

  final bool isTab;
  final bool? initialIsRent;
  final String? initialCity;
  final String? initialType;

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  late PropertyFilters _filters = PropertyFilters(
    isRent: widget.initialIsRent,
    city: widget.initialCity,
    types: widget.initialType == null ? {} : {widget.initialType!},
  );
  PropertySort _sort = PropertySort.newest;
  final Set<String> _savedIds = {};

  List<Property> get _results {
    var list = dummyProperties.where((p) {
      if (_filters.isRent != null && p.isRent != _filters.isRent) return false;
      if (_filters.city != null && p.city != _filters.city) return false;
      if (_filters.types.isNotEmpty && !_filters.types.contains(p.type))
        return false;
      if (_filters.bedrooms != null) {
        if (_filters.bedrooms == 5) {
          if (p.beds < 5) return false;
        } else if (p.beds != _filters.bedrooms) {
          return false;
        }
      }
      if (_filters.maxPrice != null && p.priceValue > _filters.maxPrice!)
        return false;
      return true;
    }).toList();
    if (_sort == PropertySort.priceLow) {
      list.sort((a, b) => a.priceValue.compareTo(b.priceValue));
    } else if (_sort == PropertySort.priceHigh) {
      list.sort((a, b) => b.priceValue.compareTo(a.priceValue));
    }
    return list;
  }

  Future<void> _openFilters() async {
    final result = await Navigator.of(context).push<PropertyFilters>(
      MaterialPageRoute(builder: (_) => FiltersScreen(initial: _filters)),
    );
    if (result != null) setState(() => _filters = result);
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    final body = Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openFilters,
                  icon: const Icon(Icons.tune, size: 18),
                  label: Text(
                    _filters.isActive ? 'Filters (active)' : 'Filters',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<PropertySort>(
                  value: _sort,
                  underline: const SizedBox.shrink(),
                  isDense: true,
                  items: const [
                    DropdownMenuItem(
                      value: PropertySort.newest,
                      child: Text(
                        'Newest first',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    DropdownMenuItem(
                      value: PropertySort.priceLow,
                      child: Text(
                        'Price: Low to High',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    DropdownMenuItem(
                      value: PropertySort.priceHigh,
                      child: Text(
                        'Price: High to Low',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                  onChanged: (v) =>
                      setState(() => _sort = v ?? PropertySort.newest),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${results.length} results · Updated moments ago',
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
        Expanded(
          child: results.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No properties match these filters.\nTry Reset all in Filters.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted, height: 1.5),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                  children: [
                    for (final p in results)
                      PropertyCard(
                        property: p,
                        saved: _savedIds.contains(p.id),
                        onSaveTap: () => setState(() {
                          if (_savedIds.contains(p.id)) {
                            _savedIds.remove(p.id);
                          } else {
                            _savedIds.add(p.id);
                          }
                        }),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PropertyDetailScreen(property: p),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );

    if (widget.isTab) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Properties',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: body,
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Properties',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: body,
    );
  }
}
