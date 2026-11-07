import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import 'package:get/get.dart';

import '../../controllers/saved_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/property_card.dart';
import '../chat/chats_screen.dart';
import '../info/info_screen.dart';
import '../profile/seller_profile_screen.dart';

/// Property detail — mirrors the website's detail page (checked
/// 2026-11-06): gallery with lightbox, title/location/price, meta
/// line, For Sale + Verified chips, About this property, Amenities,
/// Location with the privacy note, Property details rows, the
/// "Listed by this owner" seller card (Reveal owner's number /
/// WhatsApp / Message in App, Report this listing), and the safety
/// reminder box. The site has NO related-properties section here.
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

  void _openLightbox() {
    var index = _photoIndex;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              PageView.builder(
                itemCount: p.photoCount,
                controller: PageController(initialPage: _photoIndex),
                onPageChanged: (i) => setDialogState(() => index = i),
                itemBuilder: (_, _) => PropertyPhoto(property: p, height: 420),
              ),
              Positioned(
                top: 14,
                left: 0,
                right: 0,
                child: Text(
                  '${index + 1} / ${p.photoCount}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
              ),
              Positioned(
                bottom: 18,
                left: 0,
                right: 0,
                child: Text(
                  '${p.title} – ${index + 1}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
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

  @override
  Widget build(BuildContext context) {
    final sellerListings = dummyProperties
        .where((x) => x.sellerName == p.sellerName)
        .length;
    final metaParts = <String>[
      p.sizeLabel,
      if (p.beds > 0) '${p.beds} beds',
      if (p.baths > 0) '${p.baths} baths',
      '${p.views} views',
      p.postedLabel,
    ];
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
          Obx(() {
            final savedIds = SavedController.to.ids;
            final isSaved = savedIds.contains(p.id);
            return IconButton(
              icon: Icon(
                isSaved ? Icons.favorite : Icons.favorite_border,
                color: isSaved ? Colors.red : AppColors.textPrimary,
              ),
              onPressed: () => SavedController.to.toggle(p.id),
            );
          }),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gallery — tap opens the lightbox, like the website
            GestureDetector(
              onTap: _openLightbox,
              child: Stack(
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
                        '${p.photoCount} photo${p.photoCount == 1 ? '' : 's'}',
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
                  const SizedBox(height: 8),
                  Text(
                    metaParts.join(' · '),
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          p.isRent ? 'For Rent' : 'For Sale',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        backgroundColor: AppColors.emeraldDark,
                        side: BorderSide.none,
                      ),
                      const SizedBox(width: 8),
                      const Chip(
                        avatar: Icon(
                          Icons.shield_outlined,
                          size: 15,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          'Verified listing',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        backgroundColor: AppColors.mint,
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                  _heading('About this property'),
                  Text(
                    p.description.isEmpty
                        ? 'No description added yet'
                        : p.description,
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
                    const SizedBox(height: 6),
                    const Text(
                      'No additional amenities',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                  _heading('Location'),
                  Text(
                    p.location,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                  const Text(
                    'Map location is approximate for privacy; exact location is shared by the owner after contact.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                      height: 1.45,
                    ),
                  ),
                  _heading('Property details'),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _detailRow('Property Type', p.type),
                        _detailRow(
                          'Purpose',
                          p.isRent ? 'For Rent' : 'For Sale',
                        ),
                        _detailRow('City', p.city),
                        _detailRow('Society/Area', p.area),
                        _detailRow('Area', p.sizeLabel),
                        _detailRow('Bedrooms', p.beds > 0 ? '${p.beds}' : '—'),
                        _detailRow(
                          'Bathrooms',
                          p.baths > 0 ? '${p.baths}' : '—',
                        ),
                        _detailRow('Added', p.addedDate),
                        _detailRow('Views', '${p.views}'),
                        _detailRow('Verify Status', 'Verified'),
                      ],
                    ),
                  ),
                  _heading('Listed by this owner'),
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
                                      '$sellerListings listing${sellerListings == 1 ? '' : 's'} · ${p.sellerType}',
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
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            foregroundColor: AppColors.textPrimary,
                          ),
                          onPressed: () => setState(() => _phoneShown = true),
                          icon: const Icon(Icons.call_outlined, size: 18),
                          label: Text(
                            _phoneShown ? p.phoneFull : "Reveal owner's number",
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 9),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.whatsapp,
                          ),
                          onPressed: () => _soon('WhatsApp'),
                          child: const Text('WhatsApp'),
                        ),
                        const SizedBox(height: 9),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          onPressed: _openChat,
                          child: const Text('Message in App'),
                        ),
                        const SizedBox(height: 6),
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
                        const Text(
                          'By contacting, you agree to our Safety Guidelines.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.mint,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Stay safe while searching',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Avoid making advance payments until you've visited the property and verified the owner's identity. For full guidance, see our Safety Guidelines.",
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  const InfoScreen(kind: InfoKind.safety),
                            ),
                          ),
                          child: const Text('Read Safety Guidelines'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
