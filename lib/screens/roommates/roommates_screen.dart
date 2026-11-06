import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_theme.dart';

/// Roommates — the website's /roommates section: find a roommate
/// or post your profile, with purpose / city / room type / gender /
/// budget filters. Design only.
class RoommatesScreen extends StatefulWidget {
  const RoommatesScreen({super.key});

  @override
  State<RoommatesScreen> createState() => _RoommatesScreenState();
}

class _RoommatesScreenState extends State<RoommatesScreen> {
  String _purpose = 'All';
  String? _budgetChip;

  static const _budgetChips = ['< 15k', '15k – 25k', '25k – 40k', '40k+'];

  List<RoommateProfile> get _list => dummyRoommates
      .where((r) => _purpose == 'All' || r.purpose == _purpose)
      .toList();

  void _soon(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Text('$action — design only.'),
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
          'Roommates',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
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
              decoration: InputDecoration(
                hintText:
                    'Search university, area or landmark (FAST, LUMS, DHA…)',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              onSubmitted: (_) => _soon('Search roommates'),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                for (final p in ['All', 'Need Room', 'Have Room'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _purpose = p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _purpose == p
                              ? AppColors.primary
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _purpose == p
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          p,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: _purpose == p
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Monthly Budget (PKR)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 7),
            Wrap(
              spacing: 8,
              children: [
                for (final b in _budgetChips)
                  GestureDetector(
                    onTap: () => setState(
                      () => _budgetChip = _budgetChip == b ? null : b,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _budgetChip == b ? AppColors.mint : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _budgetChip == b
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        b,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${_list.length} listings',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            for (final r in _list)
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
                            r.initial,
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
                                r.name,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${r.area}, ${r.city} • ${r.postedLabel}',
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
                            r.purpose,
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
                      r.title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${r.budgetLabel}  •  ${r.roomType}  •  ${r.gender}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
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
                            onPressed: () => _soon('View profile'),
                            child: const Text('View Profile'),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(40),
                            ),
                            onPressed: () => _soon('Send message'),
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
              onPressed: () => _soon('Post Roommate Ad'),
              child: const Text('Post Roommate Ad'),
            ),
          ],
        ),
      ),
    );
  }
}
