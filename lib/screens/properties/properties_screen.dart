import 'package:flutter/material.dart';

import '../../controllers/catalog_controller.dart';
import '../../data/dummy_data.dart';
import '../../services/catalog_service.dart';
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
    this.initialTypes,
    this.initialSociety,
    this.initialSizeValue,
    this.initialUnit,
  });

  final bool isTab;
  final bool? initialIsRent;
  final String? initialCity;
  final String? initialType;
  final Set<String>? initialTypes;
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
    types:
        widget.initialTypes ??
        (widget.initialType == null ? {} : {widget.initialType!}),
    sizeValue: widget.initialSizeValue,
    unit: widget.initialUnit,
  );
  PropertySort _sort = PropertySort.newest;

  /// Live listings from the API (GET /listings).
  List<Property> _all = [];
  List<Property> _buyAlso = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String get _sortBy => switch (_sort) {
    PropertySort.newest => 'newest',
    PropertySort.priceLow => 'price_asc',
    PropertySort.priceHigh => 'price_desc',
  };

  /// Loads listings from the API. The server applies purpose,
  /// single type, city, price range, 5+ bedrooms and sorting;
  /// the remaining filters are applied on the result below.
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final (listings, _) = await CatalogService.fetchListings(
        intent: _filters.isRent == null
            ? null
            : (_filters.isRent! ? 'rent' : 'sell'),
        propertyType: _filters.types.length == 1 ? _filters.types.first : null,
        city: _filters.city,
        minPrice: _filters.minPrice,
        maxPrice: _filters.maxPrice,
        minBedrooms: _filters.bedrooms == 5 ? 5 : null,
        sortBy: _sortBy,
      );
      var buyAlso = const <Property>[];
      if (_filters.isRent == true) {
        final (sellListings, _) = await CatalogService.fetchListings(
          intent: 'sell',
        );
        buyAlso = sellListings.map((l) => l.toProperty()).toList();
      }
      if (!mounted) return;
      final properties = listings.map((l) => l.toProperty()).toList();
      CatalogController.to.register(properties);
      CatalogController.to.register(buyAlso);
      setState(() {
        _all = properties;
        _buyAlso = buyAlso;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// Filters the server does not apply: society text, multiple
  /// types, exact bedrooms, size and amenities.
  List<Property> _results(List<Property> source) {
    return source.where((p) {
      if (_filters.society != null &&
          !p.area.toLowerCase().contains(_filters.society!.toLowerCase())) {
        return false;
      }
      if (_filters.types.length != 1 &&
          _filters.types.isNotEmpty &&
          !_filters.types.contains(p.type)) {
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
      if (_filters.bedrooms != null && _filters.bedrooms != 5) {
        if (p.beds != _filters.bedrooms) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _openFilters() async {
    final result = await Navigator.of(context).push<PropertyFilters>(
      MaterialPageRoute(builder: (_) => FiltersScreen(initial: _filters)),
    );
    if (result != null) {
      setState(() => _filters = result);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _results(_all);
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
                  onChanged: (v) {
                    setState(() => _sort = v ?? PropertySort.newest);
                    _load();
                  },
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
                    onDeleted: () {
                      setState(() => _filters.isRent = null);
                      _load();
                    },
                  ),
                if (_filters.city != null)
                  Chip(
                    label: Text(_filters.city!),
                    onDeleted: () {
                      setState(() => _filters.city = null);
                      _load();
                    },
                  ),
                if (_filters.society != null)
                  Chip(
                    label: Text(_filters.society!),
                    onDeleted: () {
                      setState(() => _filters.society = null);
                      _load();
                    },
                  ),
                for (final type in _filters.types)
                  Chip(
                    label: Text(type),
                    onDeleted: () {
                      setState(() => _filters.types.remove(type));
                      _load();
                    },
                  ),
                if (_filters.unit != null)
                  Chip(
                    label: Text(
                      '${_filters.sizeValue?.toString() ?? ''} ${_filters.unit!}'
                          .trim(),
                    ),
                    onDeleted: () {
                      setState(() {
                        _filters.unit = null;
                        _filters.sizeValue = null;
                      });
                      _load();
                    },
                  ),
                if (_filters.amenities.isNotEmpty)
                  Chip(
                    label: Text('${_filters.amenities.length} amenities'),
                    onDeleted: () {
                      setState(() => _filters.amenities = {});
                      _load();
                    },
                  ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _filters.isRent == null
                    ? 'Properties across Pakistan'
                    : _filters.isRent!
                    ? 'Properties for rent across Pakistan'
                    : 'Properties for sale across Pakistan',
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${results.length} results · Updated moments ago',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Could not load properties.\nCheck your internet connection.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _load,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : results.isEmpty
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
                    if (_filters.isRent == true) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'RECOMMENDED PROPERTIES — OPTION TO BUY INSTEAD',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.emeraldDark,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Can't find a property to rent? Explore verified properties for sale across Pakistan and consider investing.",
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textMuted,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final p in _buyAlso)
                        PropertyCard(
                          property: p,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => PropertyDetailScreen(property: p),
                            ),
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            setState(() => _filters.isRent = false);
                            _load();
                          },
                          child: const Text('View all for buy'),
                        ),
                      ),
                    ],
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
