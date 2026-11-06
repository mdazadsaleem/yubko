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
    this.initialSociety,
    this.initialSizeValue,
    this.initialUnit,
  });

  final bool isTab;
  final bool? initialIsRent;
  final String? initialCity;
  final String? initialType;
  final String? initialSociety;
  final double? initialSizeValue;
  final String? initialUnit;

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  late PropertyFilters _filters = PropertyFilters(
    isRent: widget.initialIsRent,
    city: widget.initialCity,
    society: widget.initialSociety,
    types: widget.initialType == null ? {} : {widget.initialType!},
    sizeValue: widget.initialSizeValue,
    unit: widget.initialUnit,
  );
  PropertySort _sort = PropertySort.newest;

  List<Property> get _results {
    var list = dummyProperties.where((p) {
      if (_filters.isRent != null && p.isRent != _filters.isRent) return false;
      if (_filters.city != null && p.city != _filters.city) return false;
      if (_filters.society != null &&
          !p.area.toLowerCase().contains(_filters.society!.toLowerCase())) {
        return false;
      }
      if (_filters.types.isNotEmpty && !_filters.types.contains(p.type)) {
        return false;
      }
      if (_filters.minPrice != null && p.priceValue < _filters.minPrice!) {
        return false;
      }
      if (_filters.sizeValue != null || _filters.unit != null) {
        if (_filters.unit != null &&
            !p.sizeLabel.toLowerCase().contains(_filters.unit!.toLowerCase())) {
          return false;
        }
        if (_filters.sizeValue != null) {
          final match = RegExp(
            r'[0-9]+(?:\.[0-9]+)?',
          ).firstMatch(p.sizeLabel.replaceAll(',', ''));
          final propertySize = match == null
              ? null
              : double.tryParse(match.group(0)!);
          if (propertySize != _filters.sizeValue) return false;
        }
      }
      if (_filters.amenities.isNotEmpty &&
          !p.amenities.toSet().containsAll(_filters.amenities)) {
        return false;
      }
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
        if (_filters.isActive)
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                if (_filters.isRent != null)
                  Chip(
                    label: Text(_filters.isRent! ? 'Rent' : 'Buy'),
                    onDeleted: () => setState(() => _filters.isRent = null),
                  ),
                if (_filters.city != null)
                  Chip(
                    label: Text(_filters.city!),
                    onDeleted: () => setState(() => _filters.city = null),
                  ),
                if (_filters.society != null)
                  Chip(
                    label: Text(_filters.society!),
                    onDeleted: () => setState(() => _filters.society = null),
                  ),
                for (final type in _filters.types)
                  Chip(
                    label: Text(type),
                    onDeleted: () =>
                        setState(() => _filters.types.remove(type)),
                  ),
                if (_filters.unit != null)
                  Chip(
                    label: Text(
                      '${_filters.sizeValue?.toString() ?? ''} ${_filters.unit!}'
                          .trim(),
                    ),
                    onDeleted: () => setState(() {
                      _filters.unit = null;
                      _filters.sizeValue = null;
                    }),
                  ),
                if (_filters.amenities.isNotEmpty)
                  Chip(
                    label: Text('${_filters.amenities.length} amenities'),
                    onDeleted: () => setState(() => _filters.amenities = {}),
                  ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${results.length} properties found · Updated recently',
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
