import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_theme.dart';

const roommateRoomTypes = [
  'Private Room',
  'Shared Room (2 persons)',
  'Shared Room (3 persons)',
  'Shared Room (4 persons)',
  'Bed Space',
  'Entire Flat',
  'Studio',
];

/// Post Roommate Ad — design-only form for the website's
/// Roommates section. Fields mirror the roommate filters:
/// purpose, city/area, room type, gender preference, monthly
/// budget, non-smoker preference and a short description.
class PostRoommateScreen extends StatefulWidget {
  const PostRoommateScreen({super.key});

  @override
  State<PostRoommateScreen> createState() => _PostRoommateScreenState();
}

class _PostRoommateScreenState extends State<PostRoommateScreen> {
  String _purpose = 'Need Room';
  String? _city;
  String? _roomType;
  String _gender = 'Any Gender';
  bool _nonSmoker = false;
  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  final _budgetController = TextEditingController();
  final _phoneController = TextEditingController();
  final _aboutController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _budgetController.dispose();
    _phoneController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    ),
  );

  void _post() {
    if (_nameController.text.trim().isEmpty ||
        _city == null ||
        _roomType == null ||
        _budgetController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text(
            'Please add your name, city, room type and monthly budget.',
          ),
        ),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Design only',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Your roommate profile is ready in the design. It will be posted when the developer APIs are connected.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
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
          'Post Roommate Ad',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _label('I am'),
            Row(
              children: [
                for (final purpose in ['Need Room', 'Have Room'])
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _purpose = purpose),
                      child: Container(
                        margin: EdgeInsets.only(
                          right: purpose == 'Need Room' ? 8 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: _purpose == purpose
                              ? AppColors.primary
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primary),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          purpose,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _purpose == purpose
                                ? Colors.white
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            _label('Your Name'),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'e.g. Ali Hamza'),
            ),
            _label('City'),
            DropdownButtonFormField<String>(
              initialValue: _city,
              hint: const Text('Select city'),
              items: [
                for (final city in dummyCities)
                  DropdownMenuItem(value: city, child: Text(city)),
              ],
              onChanged: (value) => setState(() => _city = value),
            ),
            _label('Area / Society'),
            TextField(
              controller: _areaController,
              decoration: const InputDecoration(
                hintText: 'e.g. Johar Town, DHA, G-13',
              ),
            ),
            _label('Room Type'),
            DropdownButtonFormField<String>(
              initialValue: _roomType,
              hint: const Text('Select room type'),
              items: [
                for (final type in roommateRoomTypes)
                  DropdownMenuItem(value: type, child: Text(type)),
              ],
              onChanged: (value) => setState(() => _roomType = value),
            ),
            _label('Gender Preference'),
            Wrap(
              spacing: 8,
              children: [
                for (final gender in ['Any Gender', 'Male Only', 'Female Only'])
                  ChoiceChip(
                    label: Text(gender),
                    selected: _gender == gender,
                    selectedColor: AppColors.mint,
                    onSelected: (_) => setState(() => _gender = gender),
                  ),
              ],
            ),
            _label('Monthly Budget (PKR)'),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'e.g. 20000'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Non-smoker',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Show this preference on my profile'),
              value: _nonSmoker,
              activeThumbColor: AppColors.emerald,
              onChanged: (value) => setState(() => _nonSmoker = value),
            ),
            _label('Phone / WhatsApp'),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '3XX XXXXXXX',
                prefixText: '+92 ',
              ),
            ),
            _label('About / Requirement'),
            TextField(
              controller: _aboutController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Student / professional, move-in date, habits or house rules…',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: _post,
              child: const Text('Post Roommate Ad'),
            ),
          ],
        ),
      ),
    );
  }
}
