import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_theme.dart';
import '../chat/chats_screen.dart';
import 'post_roommate_screen.dart';

enum RoommateSort { newest, budgetLow, budgetHigh }

/// Roommates — the website's /roommates section: search, purpose,
/// city, room type, gender, budget and non-smoker filters, sort,
/// profile cards and Post Roommate Ad. Design only.
class RoommatesScreen extends StatefulWidget {
  const RoommatesScreen({super.key});

  @override
  State<RoommatesScreen> createState() => _RoommatesScreenState();
}

class _RoommatesScreenState extends State<RoommatesScreen> {
  final _searchController = TextEditingController();
  String _purpose = 'All';
  String? _city;
  String? _roomType;
  String _gender = 'Any Gender';
  String? _budgetChip;
  bool _nonSmokerOnly = false;
  RoommateSort _sort = RoommateSort.newest;

  static const _budgetChips = ['< 15k', '15k – 25k', '25k – 40k', '40k+'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _budgetMatches(RoommateProfile profile) {
    final budget = profile.budgetValue;
    return switch (_budgetChip) {
      '< 15k' => budget < 15000,
      '15k – 25k' => budget >= 15000 && budget <= 25000,
      '25k – 40k' => budget > 25000 && budget <= 40000,
      '40k+' => budget > 40000,
      _ => true,
    };
  }

  List<RoommateProfile> get _list {
    final query = _searchController.text.trim().toLowerCase();
    final list = dummyRoommates.where((profile) {
      if (_purpose != 'All' && profile.purpose != _purpose) return false;
      if (_city != null && profile.city != _city) return false;
      if (_roomType != null && profile.roomType != _roomType) return false;
      if (_gender == 'Male Only' && profile.gender != 'Male') return false;
      if (_gender == 'Female Only' && profile.gender != 'Female') return false;
      if (_nonSmokerOnly && !profile.nonSmoker) return false;
      if (!_budgetMatches(profile)) return false;
      if (query.isNotEmpty) {
        final haystack =
            '${profile.name} ${profile.title} ${profile.city} '
                    '${profile.area} ${profile.roomType}'
                .toLowerCase();
        if (!haystack.contains(query)) return false;
      }
      return true;
    }).toList();
    if (_sort == RoommateSort.budgetLow) {
      list.sort((a, b) => a.budgetValue.compareTo(b.budgetValue));
    } else if (_sort == RoommateSort.budgetHigh) {
      list.sort((a, b) => b.budgetValue.compareTo(a.budgetValue));
    }
    return list;
  }

  void _viewProfile(RoommateProfile profile) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      profile.initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${profile.area}, ${profile.city} • ${profile.postedLabel}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(profile.purpose),
                    backgroundColor: AppColors.mint,
                    side: BorderSide.none,
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Text(
                profile.title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              _profileFact(
                Icons.payments_outlined,
                'Monthly budget',
                profile.budgetLabel,
              ),
              _profileFact(Icons.bed_outlined, 'Room type', profile.roomType),
              _profileFact(Icons.person_outline, 'Gender', profile.gender),
              _profileFact(
                Icons.smoke_free_outlined,
                'Smoking',
                profile.nonSmoker ? 'Non-smoker' : 'No preference shown',
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  _message(profile);
                },
                icon: const Icon(Icons.chat_bubble_outline, size: 19),
                label: const Text('Message'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileFact(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 19, color: AppColors.primary),
          const SizedBox(width: 9),
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _message(RoommateProfile profile) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatThreadScreen(
          sellerName: profile.name,
          propertyTitle: profile.title,
        ),
      ),
    );
  }

  Widget _filterLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 7),
    child: Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final list = _list;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Roommates',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PostRoommateScreen(),
              ),
            ),
            child: const Text(
              'Post Ad',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Find Your Roommate & Shared Space',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Connect with verified students, professionals & flatmates across Pakistan.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText:
                    'Search university, area or landmark (FAST, LUMS, DHA…)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear, size: 19),
                        onPressed: () => setState(_searchController.clear),
                      ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.fromLTRB(13, 3, 13, 13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _filterLabel('Purpose'),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final purpose in ['All', 'Need Room', 'Have Room'])
                        ChoiceChip(
                          label: Text(purpose),
                          selected: _purpose == purpose,
                          selectedColor: AppColors.mint,
                          onSelected: (_) => setState(() => _purpose = purpose),
                        ),
                    ],
                  ),
                  _filterLabel('City'),
                  DropdownButtonFormField<String>(
                    initialValue: _city,
                    hint: const Text('All Cities'),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Cities'),
                      ),
                      for (final city in dummyCities)
                        DropdownMenuItem(value: city, child: Text(city)),
                    ],
                    onChanged: (value) => setState(() => _city = value),
                  ),
                  _filterLabel('Room Type'),
                  DropdownButtonFormField<String>(
                    initialValue: _roomType,
                    hint: const Text('All Room Types'),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Room Types'),
                      ),
                      for (final type in roommateRoomTypes)
                        DropdownMenuItem(value: type, child: Text(type)),
                    ],
                    onChanged: (value) => setState(() => _roomType = value),
                  ),
                  _filterLabel('Gender Preference'),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final gender in [
                        'Any Gender',
                        'Male Only',
                        'Female Only',
                      ])
                        ChoiceChip(
                          label: Text(gender),
                          selected: _gender == gender,
                          selectedColor: AppColors.mint,
                          onSelected: (_) => setState(() => _gender = gender),
                        ),
                    ],
                  ),
                  _filterLabel('Monthly Budget (PKR)'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final budget in _budgetChips)
                        ChoiceChip(
                          label: Text(budget),
                          selected: _budgetChip == budget,
                          selectedColor: AppColors.mint,
                          onSelected: (_) => setState(
                            () => _budgetChip = _budgetChip == budget
                                ? null
                                : budget,
                          ),
                        ),
                    ],
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    title: const Text('Non-smoker only'),
                    value: _nonSmokerOnly,
                    onChanged: (value) =>
                        setState(() => _nonSmokerOnly = value ?? false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Available Roommates & Spaces across Pakistan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${list.length} listings found · Updated recently',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                const Text(
                  'Sort by',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 7),
                DropdownButton<RoommateSort>(
                  value: _sort,
                  underline: const SizedBox.shrink(),
                  isDense: true,
                  items: const [
                    DropdownMenuItem(
                      value: RoommateSort.newest,
                      child: Text(
                        'Newest first',
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                    DropdownMenuItem(
                      value: RoommateSort.budgetLow,
                      child: Text(
                        'Budget: Low to High',
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                    DropdownMenuItem(
                      value: RoommateSort.budgetHigh,
                      child: Text(
                        'Budget: High to Low',
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _sort = value ?? RoommateSort.newest),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (list.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Column(
                  children: [
                    Icon(
                      Icons.group_outlined,
                      size: 48,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No roommates match these filters.',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Try another city, room type or budget.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            for (final profile in list)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 21,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            profile.initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${profile.area}, ${profile.city} • ${profile.postedLabel}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.mint,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            profile.purpose,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      profile.title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${profile.budgetLabel}  •  ${profile.roomType}  •  ${profile.gender}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    if (profile.nonSmoker) ...[
                      const SizedBox(height: 7),
                      const Row(
                        children: [
                          Icon(
                            Icons.smoke_free_outlined,
                            size: 15,
                            color: AppColors.emeraldDark,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Non-smoker',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.emeraldDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(40),
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9),
                              ),
                              foregroundColor: AppColors.primary,
                            ),
                            onPressed: () => _viewProfile(profile),
                            child: const Text('View Profile'),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(40),
                            ),
                            onPressed: () => _message(profile),
                            child: const Text('Message'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 6),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PostRoommateScreen(),
                ),
              ),
              child: const Text('Post Roommate Ad'),
            ),
          ],
        ),
      ),
    );
  }
}
