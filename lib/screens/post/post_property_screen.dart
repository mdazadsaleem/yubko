import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_theme.dart';

/// Post Property — the website's 3-step free posting flow:
/// 1 Essentials, 2 Photos, 3 Publish. Design only; the real form
/// fields are confirmed with the developer in Phase 2.
class PostPropertyScreen extends StatefulWidget {
  const PostPropertyScreen({super.key, this.isTab = false});

  final bool isTab;

  @override
  State<PostPropertyScreen> createState() => _PostPropertyScreenState();
}

class _PostPropertyScreenState extends State<PostPropertyScreen> {
  int _step = 0;
  bool _isRent = false;
  String? _type;
  String? _city;
  String? _unit;
  int _beds = 3;
  int _baths = 2;
  int _photos = 0;
  String _status = 'Ready to move';
  final Set<String> _amenities = {};
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _sizeController = TextEditingController();
  final _descController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _sizeController.dispose();
    _descController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    ),
  );

  Widget _stepsBar() {
    const labels = ['Essentials', 'Photos', 'Publish'];
    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: i <= _step
                      ? AppColors.primary
                      : AppColors.border,
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: i <= _step ? Colors.white : AppColors.textMuted,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: i == _step ? FontWeight.w800 : FontWeight.w500,
                    color: i == _step ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (i < 2)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 22),
                color: i < _step ? AppColors.primary : AppColors.border,
              ),
            ),
        ],
      ],
    );
  }

  Widget _stepEssentials() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Purpose'),
        Row(
          children: [
            for (final rent in [false, true])
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isRent = rent),
                  child: Container(
                    margin: EdgeInsets.only(right: rent ? 0 : 8),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: _isRent == rent ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      rent ? 'For Rent' : 'For Sale',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _isRent == rent
                            ? Colors.white
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        _label('Property Type'),
        DropdownButtonFormField<String>(
          initialValue: _type,
          hint: const Text('Select type'),
          items: [
            for (final t in dummyPropertyTypes)
              DropdownMenuItem(value: t, child: Text(t)),
          ],
          onChanged: (v) => setState(() => _type = v),
        ),
        _label('Title'),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'e.g. 5 Marla Brand New House',
          ),
        ),
        _label('City'),
        DropdownButtonFormField<String>(
          initialValue: _city,
          hint: const Text('Select city'),
          items: [
            for (final c in dummyCities)
              DropdownMenuItem(value: c, child: Text(c)),
          ],
          onChanged: (v) => setState(() => _city = v),
        ),
        _label('Society / Area'),
        const TextField(
          decoration: InputDecoration(hintText: 'e.g. Eden Gardens'),
        ),
        _label('Property Size'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _sizeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'e.g. 5'),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _unit,
                hint: const Text('Unit'),
                items: [
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
        _label('Asking Price (PKR)'),
        TextField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: _isRent ? 'e.g. 50000 (per month)' : 'e.g. 14500000',
          ),
        ),
        _label('Property Status'),
        DropdownButtonFormField<String>(
          initialValue: _status,
          items: const [
            DropdownMenuItem(
              value: 'Ready to move',
              child: Text('Ready to move'),
            ),
            DropdownMenuItem(
              value: 'Under construction',
              child: Text('Under construction'),
            ),
            DropdownMenuItem(
              value: 'Possession Available',
              child: Text('Possession Available'),
            ),
          ],
          onChanged: (v) => setState(() => _status = v ?? _status),
        ),
        _label('Contact Phone / WhatsApp'),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: '3XX XXXXXXX',
            prefixText: '+92 ',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
        _label('Bedrooms / Bathrooms'),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: _beds,
                items: [
                  for (var i = 0; i <= 10; i++)
                    DropdownMenuItem(value: i, child: Text('$i Beds')),
                ],
                onChanged: (v) => setState(() => _beds = v ?? 0),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: _baths,
                items: [
                  for (var i = 0; i <= 10; i++)
                    DropdownMenuItem(value: i, child: Text('$i Baths')),
                ],
                onChanged: (v) => setState(() => _baths = v ?? 0),
              ),
            ),
          ],
        ),
        _label('Description'),
        TextField(
          controller: _descController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Describe your property…',
          ),
        ),
        _label('Amenities'),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final a in dummyAmenities.take(10))
              FilterChip(
                label: Text(a, style: const TextStyle(fontSize: 12)),
                selected: _amenities.contains(a),
                selectedColor: AppColors.mint,
                onSelected: (v) => setState(() {
                  if (v) {
                    _amenities.add(a);
                  } else {
                    _amenities.remove(a);
                  }
                }),
              ),
          ],
        ),
      ],
    );
  }

  Widget _stepPhotos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload clear photos',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Show bedrooms, living areas and the front of the property to attract genuine inquiries.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 9,
          crossAxisSpacing: 9,
          children: [
            for (var i = 0; i < 6; i++)
              GestureDetector(
                onTap: () => setState(() => _photos = i < _photos ? i : i + 1),
                child: Container(
                  decoration: BoxDecoration(
                    color: i < _photos ? AppColors.mint : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        i < _photos ? Icons.photo : Icons.add_a_photo_outlined,
                        color: AppColors.primary,
                        size: 26,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        i < _photos ? 'Photo ${i + 1}' : 'Add photo',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _photos == 0
              ? 'Tap a box to add photos (design only — no real upload yet).'
              : '$_photos photo(s) added. Tap a filled box to remove it and the photos after it.',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _stepPublish() {
    final title = _titleController.text.isEmpty
        ? '(your title)'
        : _titleController.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review & publish',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_isRent ? 'For Rent' : 'For Sale'} • ${_type ?? 'Type not selected'} • ${_city ?? 'City not selected'}',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                'Size: ${_sizeController.text.isEmpty ? '—' : _sizeController.text} ${_unit ?? ''} • $_beds Beds • $_baths Baths',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                'Status: $_status • Contact: ${_phoneController.text.isEmpty ? '—' : '+92 ${_phoneController.text}'}',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textMuted,
                ),
              ),
              if (_descController.text.trim().isNotEmpty)
                Text(
                  'Description: ${_descController.text.trim()}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                  ),
                ),
              if (_amenities.isNotEmpty)
                Text(
                  'Amenities: ${_amenities.join(', ')}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                  ),
                ),
              Text(
                'Price: ${_priceController.text.isEmpty ? '—' : 'PKR ${_priceController.text}'} • Photos: $_photos',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Icon(Icons.check_circle, size: 17, color: AppColors.emerald),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Posting is 100% free and goes live immediately.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _validateEssentials() {
    final missing = <String>[
      if (_type == null) 'property type',
      if (_titleController.text.trim().isEmpty) 'title',
      if (_city == null) 'city',
      if (_sizeController.text.trim().isEmpty || _unit == null) 'size and unit',
      if (_priceController.text.trim().isEmpty) 'asking price',
      if (_phoneController.text.trim().isEmpty) 'contact phone',
    ];
    if (missing.isEmpty) return true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.error,
        content: Text('Please add: ${missing.join(', ')}.'),
      ),
    );
    return false;
  }

  void _publish() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Design only',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Your property looks ready! Real publishing starts when the developer APIs are connected in Phase 2.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stepsBar(),
          const SizedBox(height: 8),
          if (_step == 0) _stepEssentials(),
          if (_step == 1) _stepPhotos(),
          if (_step == 2) _stepPublish(),
          const SizedBox(height: 24),
          Row(
            children: [
              if (_step > 0)
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      foregroundColor: AppColors.textPrimary,
                    ),
                    onPressed: () => setState(() => _step--),
                    child: const Text('Back'),
                  ),
                ),
              if (_step > 0) const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_step == 0 && !_validateEssentials()) return;
                    if (_step < 2) {
                      setState(() => _step++);
                    } else {
                      _publish();
                    }
                  },
                  child: Text(_step == 2 ? 'Publish Free' : 'Next'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: !widget.isTab,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Post Property Free',
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
