import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../data/saved_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/property_card.dart';
import '../chat/chats_screen.dart';
import '../profile/seller_profile_screen.dart';

/// Property detail — the website's detail page in mobile form:
/// gallery, price, key facts, description, location map, seller
/// card with Chat / Call / WhatsApp, related properties.
class PropertyDetailScreen extends StatefulWidget {
  const PropertyDetailScreen({super.key, required this.property});

  final Property property;

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  bool _phoneShown = false;
  int _photoIndex = 0;

  Property get p => widget.property;

  void _soon(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Text('$action — design only.'),
      ),
    );
  }

  Widget _fact(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 19, color: AppColors.primary),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 9),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
    ),
  );

  void _openChat() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ChatThreadScreen(sellerName: p.sellerName, propertyTitle: p.title),
      ),
    );
  }

  void _showPhoneDialog() {
    setState(() => _phoneShown = true);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Seller phone number',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          '${p.sellerName}\n${p.phoneFull}\n\nDesign only — calling starts after API integration.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    var reason = 'Incorrect information';
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Report this listing',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in [
                'Incorrect information',
                'Property already sold or rented',
                'Scam or suspicious behaviour',
                'Duplicate listing',
                'Other',
              ])
                RadioListTile<String>(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(item, style: const TextStyle(fontSize: 13.5)),
                  value: item,
                  groupValue: reason,
                  onChanged: (value) =>
                      setDialogState(() => reason = value ?? reason),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 42),
                backgroundColor: AppColors.error,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _soon('Report submitted ($reason)');
              },
              child: const Text('Submit report'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    foregroundColor: AppColors.primary,
                  ),
                  onPressed: _showPhoneDialog,
                  icon: const Icon(Icons.call_outlined, size: 19),
                  label: const Text('Call'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: _openChat,
                  icon: const Icon(Icons.chat_bubble_outline, size: 19),
                  label: const Text('Chat'),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.whatsapp,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed: () => _soon('Chat on WhatsApp'),
                  icon: const Icon(Icons.chat, color: Colors.white, size: 21),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final related = dummyProperties
        .where((x) => x.id != p.id && x.city == p.city)
        .toList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          p.type.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _soon('Share'),
          ),
          ValueListenableBuilder<Set<String>>(
            valueListenable: SavedStore.ids,
            builder: (context, savedIds, _) => IconButton(
              icon: Icon(
                savedIds.contains(p.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: savedIds.contains(p.id)
                    ? Colors.red
                    : AppColors.textPrimary,
              ),
              onPressed: () => SavedStore.toggle(p.id),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gallery (design placeholder)
            Stack(
              children: [
                SizedBox(
                  height: 230,
                  child: PageView.builder(
                    itemCount: p.photoCount,
                    onPageChanged: (index) =>
                        setState(() => _photoIndex = index),
                    itemBuilder: (_, _) =>
                        PropertyPhoto(property: p, height: 230),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${_photoIndex + 1} / ${p.photoCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.title,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 15,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  p.location,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Posted ${p.postedLabel}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        p.priceLabel,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Key facts — same six tiles as the website
                  Row(
                    children: [
                      Expanded(
                        child: _fact(
                          Icons.sell_outlined,
                          'PURPOSE',
                          p.isRent ? 'For Rent' : 'For Sale',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _fact(Icons.square_foot, 'SIZE', p.sizeLabel),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _fact(
                          Icons.bed_outlined,
                          'BEDROOMS',
                          p.beds > 0 ? '${p.beds} Beds' : '—',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _fact(
                          Icons.bathtub_outlined,
                          'BATHROOMS',
                          p.baths > 0 ? '${p.baths} Baths' : '—',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _fact(Icons.home_work_outlined, 'TYPE', p.type),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _fact(
                          Icons.verified_outlined,
                          'STATUS',
                          p.status,
                        ),
                      ),
                    ],
                  ),
                  _heading('Property description'),
                  Text(
                    p.description,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textPrimary,
                      height: 1.55,
                    ),
                  ),
                  if (p.amenities.isNotEmpty) ...[
                    _heading('Amenities'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final a in p.amenities)
                          Chip(
                            label: Text(
                              a,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: AppColors.mint,
                            side: BorderSide.none,
                            avatar: const Icon(
                              Icons.check,
                              size: 14,
                              color: AppColors.emeraldDark,
                            ),
                          ),
                      ],
                    ),
                  ],
                  _heading('Location'),
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.mint,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 38,
                          color: AppColors.primary,
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Map — opens with the API in Phase 2',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.pin_drop_outlined,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Approximate location: ${p.location}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _soon('Open directions'),
                        child: const Text(
                          'Open directions',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Approximate location shown. Exact address shared after contact.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  _heading('Seller'),
                  // Seller card — same as the website
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => SellerProfileScreen(property: p),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  p.sellerName[0],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
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
                                      p.sellerName,
                                      style: const TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      p.sellerType,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    const Text(
                                      'View Profile & Ratings ›',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 13),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          onPressed: _openChat,
                          child: const Text('Chat with Seller'),
                        ),
                        const SizedBox(height: 9),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            foregroundColor: AppColors.textPrimary,
                          ),
                          onPressed: () => setState(() => _phoneShown = true),
                          child: Text(
                            _phoneShown
                                ? p.phoneFull
                                : '${p.phoneMasked} — Tap to reveal',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 9),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.whatsapp,
                          ),
                          onPressed: () => _soon('Chat on WhatsApp'),
                          child: const Text('Chat on WhatsApp'),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Never share payment details before viewing in person.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                        TextButton(
                          onPressed: _showReportDialog,
                          child: const Text(
                            'Report this listing',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (related.isNotEmpty) ...[
                    _heading(
                      p.isRent ? 'Related rentals' : 'Related properties',
                    ),
                    for (final r in related)
                      PropertyCard(
                        property: r,
                        onTap: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => PropertyDetailScreen(property: r),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
