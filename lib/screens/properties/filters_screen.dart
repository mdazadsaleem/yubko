import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_theme.dart';

/// Filter values returned by the Filters screen.
/// This is the website's /properties filter set: Purpose, Location
/// (city + society/area), Price Range, Property Type, Property Size
/// & Unit, Bedrooms and Amenities. There is no Bathrooms filter on
/// the website.
class PropertyFilters {
  PropertyFilters({
    this.isRent,
    this.city,
    this.society,
    this.types = const {},
    this.bedrooms,
    this.minPrice,
    this.maxPrice,
    this.sizeValue,
    this.unit,
    this.amenities = const {},
  });

  bool? isRent; // null = any
  String? city;
  String? society;
  Set<String> types;
  int? bedrooms; // null = any, 5 = 5+
  int? minPrice; // PKR
  int? maxPrice; // PKR
  double? sizeValue;
  String? unit;
  Set<String> amenities;

  bool get isActive =>
      isRent != null ||
      city != null ||
      (society?.isNotEmpty ?? false) ||
      types.isNotEmpty ||
      bedrooms != null ||
      minPrice != null ||
      maxPrice != null ||
      sizeValue != null ||
      unit != null ||
      amenities.isNotEmpty;
}

/// Filters screen — the website's filter panel as a full screen.
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
  late int? _minPrice = widget.initial.minPrice;
  late int? _maxPrice = widget.initial.maxPrice;
  late String? _unit = widget.initial.unit;
  late Set<String> _amenities = {...widget.initial.amenities};
  late final _societyController = TextEditingController(
    text: widget.initial.society ?? '',
  );
  late final _sizeController = TextEditingController(
    text: widget.initial.sizeValue?.toString() ?? '',
  );

  // The website's exact price steps.
  static const _priceOptions = <int?>[
    null,
    10000,
    20000,
    30000,
    50000,
    100000,
    200000,
    500000,
    1000000,
    2500000,
    5000000,
    10000000,
    20000000,
    50000000,
    100000000,
  ];

  static const _priceLabels = <int, String>{
    10000: '10,000 PKR',
    20000: '20,000 PKR',
    30000: '30,000 PKR',
    50000: '50,000 PKR',
    100000: '1 Lakh',
    200000: '2 Lakh',
    500000: '5 Lakh',
    1000000: '1 Million',
    2500000: '2.5 Million',
    5000000: '5 Million',
    10000000: '1 Crore',
    20000000: '2 Crore',
    50000000: '5 Crore',
    100000000: '10+ Crore',
  };

  @override
  void dispose() {
    _societyController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  String _priceLabel(int? value, {required bool isMin}) {
    if (value == null) return isMin ? 'Any Min' : 'Any Max';
    return _priceLabels[value] ?? 'PKR $value';
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

  Widget _priceDropdown({
    required String label,
    required int? value,
    required bool isMin,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final price in _priceOptions)
          DropdownMenuItem<int>(
            value: price,
            child: Text(
              _priceLabel(price, isMin: isMin),
              style: const TextStyle(fontSize: 13),
            ),
          ),
      ],
      onChanged: onChanged,
    );
  }

  void _reset() {
    setState(() {
      _isRent = null;
      _city = null;
      _types = {};
      _bedrooms = null;
      _minPrice = null;
      _maxPrice = null;
      _unit = null;
      _amenities = {};
      _societyController.clear();
      _sizeController.clear();
    });
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
            onPressed: _reset,
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
              decoration: const InputDecoration(labelText: 'City'),
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
            const SizedBox(height: 10),
            TextField(
              controller: _societyController,
              decoration: const InputDecoration(
                labelText: 'Society / Area',
                hintText: 'e.g. Eden Gardens, DHA, Gulberg',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            _heading('Price Range (PKR)'),
            Row(
              children: [
                Expanded(
                  child: _priceDropdown(
                    label: 'Minimum Price',
                    value: _minPrice,
                    isMin: true,
                    onChanged: (v) => setState(() => _minPrice = v),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _priceDropdown(
                    label: 'Maximum Price',
                    value: _maxPrice,
                    isMin: false,
                    onChanged: (v) => setState(() => _maxPrice = v),
                  ),
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
            _heading('Property Size'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _sizeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Size',
                      hintText: 'e.g. 5, 10, 1250',
                      prefixIcon: Icon(Icons.square_foot, size: 19),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _unit,
                    decoration: const InputDecoration(
                      labelText: 'Area Size Unit',
                    ),
                    hint: const Text('Any unit'),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Any unit'),
                      ),
                      for (final u in dummySizeUnits)
                        DropdownMenuItem(
                          value: u,
                          child: Text(u, style: const TextStyle(fontSize: 13)),
                        ),
                    ],
                    onChanged: (v) => setState(() => _unit = v),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 7),
              child: Text(
                'Marla (Normal) = 272.25 sq ft • Marla (Lahori) = 225 sq ft • Kanal = 4,500 sq ft',
                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
              ),
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
                    society: _societyController.text.trim().isEmpty
                        ? null
                        : _societyController.text.trim(),
                    types: _types,
                    bedrooms: _bedrooms,
                    minPrice: _minPrice,
                    maxPrice: _maxPrice,
                    sizeValue: double.tryParse(_sizeController.text.trim()),
                    unit: _unit,
                    amenities: _amenities,
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
