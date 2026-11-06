import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_theme.dart';

/// Filter values returned by the Filters screen (design only —
/// the same filter set as the website's /properties panel).
class PropertyFilters {
  PropertyFilters({
    this.isRent,
    this.city,
    this.types = const {},
    this.bedrooms,
    this.maxPrice,
    this.unit,
  });

  bool? isRent; // null = any
  String? city;
  Set<String> types;
  int? bedrooms; // null = any, 5 = 5+
  int? maxPrice; // PKR
  String? unit;

  bool get isActive =>
      isRent != null ||
      city != null ||
      types.isNotEmpty ||
      bedrooms != null ||
      maxPrice != null ||
      unit != null;
}

/// Filters screen — the website's filter panel as a full screen:
/// Purpose, Location, Price, Property Type, Size & Units,
/// Bedrooms, Amenities.
class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key, required this.initial});

  final PropertyFilters initial;

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  late bool? _isRent = widget.initial.isRent;
  late String? _city = widget.initial.city;
  late Set<String> _types = {...widget.initial.types};
  late int? _bedrooms = widget.initial.bedrooms;
  late int? _maxPrice = widget.initial.maxPrice;
  late String? _unit = widget.initial.unit;
  final Set<String> _amenities = {};

  static const _priceOptions = <int?>[
    null,
    50000,
    100000,
    500000,
    1000000,
    5000000,
    10000000,
    25000000,
    50000000,
    100000000,
  ];

  String _priceLabel(int? v) {
    if (v == null) return 'No max';
    if (v >= 10000000) return 'PKR ${v ~/ 10000000} Crore';
    if (v >= 100000) return 'PKR ${v ~/ 100000} Lakh';
    return 'PKR $v';
  }

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 9),
    child: Text(
      text,
      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
    ),
  );

  Widget _pill(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Filters',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              _isRent = null;
              _city = null;
              _types = {};
              _bedrooms = null;
              _maxPrice = null;
              _unit = null;
              _amenities.clear();
            }),
            child: const Text(
              'Reset all',
              style: TextStyle(
                color: AppColors.emeraldDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heading('Purpose'),
            Wrap(
              spacing: 8,
              children: [
                _pill(
                  'All',
                  _isRent == null,
                  () => setState(() => _isRent = null),
                ),
                _pill(
                  'Buy',
                  _isRent == false,
                  () => setState(() => _isRent = false),
                ),
                _pill(
                  'Rent',
                  _isRent == true,
                  () => setState(() => _isRent = true),
                ),
              ],
            ),
            _heading('Location'),
            DropdownButtonFormField<String>(
              initialValue: _city,
              hint: const Text('All Cities'),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Cities'),
                ),
                for (final c in dummyCities)
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (v) => setState(() => _city = v),
            ),
            _heading('Price Range (PKR) — Max'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in _priceOptions)
                  _pill(
                    _priceLabel(p),
                    _maxPrice == p,
                    () => setState(() => _maxPrice = p),
                  ),
              ],
            ),
            _heading('Property Type'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in dummyPropertyTypes)
                  _pill(
                    t,
                    _types.contains(t),
                    () => setState(() {
                      if (_types.contains(t)) {
                        _types.remove(t);
                      } else {
                        _types.add(t);
                      }
                    }),
                  ),
              ],
            ),
            _heading('Size Unit'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _pill(
                  'Any unit',
                  _unit == null,
                  () => setState(() => _unit = null),
                ),
                for (final u in dummySizeUnits)
                  _pill(u, _unit == u, () => setState(() => _unit = u)),
              ],
            ),
            _heading('Bedrooms'),
            Wrap(
              spacing: 8,
              children: [
                _pill(
                  'Any',
                  _bedrooms == null,
                  () => setState(() => _bedrooms = null),
                ),
                for (final b in [1, 2, 3, 4, 5])
                  _pill(
                    b == 5 ? '5+' : '$b',
                    _bedrooms == b,
                    () => setState(() => _bedrooms = b),
                  ),
              ],
            ),
            _heading('Amenities'),
            for (final a in dummyAmenities)
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(a, style: const TextStyle(fontSize: 13.5)),
                value: _amenities.contains(a),
                onChanged: (v) => setState(() {
                  if (v == true) {
                    _amenities.add(a);
                  } else {
                    _amenities.remove(a);
                  }
                }),
              ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(
                  PropertyFilters(
                    isRent: _isRent,
                    city: _city,
                    types: _types,
                    bedrooms: _bedrooms,
                    maxPrice: _maxPrice,
                    unit: _unit,
                  ),
                );
              },
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
