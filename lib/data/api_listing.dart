import 'package:flutter/material.dart';

import '../config/site_assets.dart';
import 'dummy_data.dart';

/// Models for the data APIs on server.yubko.com — the same live
/// data the yubko.com website shows (listings, popular cities,
/// public settings, roommates). Verified against the real API
/// responses on 2026-11-07.

String formatPriceLabel(int price, {required bool isRent}) {
  if (isRent) return 'PKR ${_thousands(price)} / mo';
  if (price >= 10000000) return 'PKR ${_trim(price / 10000000)} Crore';
  if (price >= 100000) return 'PKR ${_trim(price / 100000)} Lakh';
  return 'PKR ${_thousands(price)}';
}

String _thousands(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

String _trim(double v) {
  final s = v.toStringAsFixed(2);
  return s.replaceFirst(RegExp(r'\.?0+$'), '');
}

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String formatDateLabel(DateTime? d) {
  if (d == null) return '—';
  return '${d.day} ${_months[d.month - 1]} ${d.year}';
}

String formatPostedLabel(DateTime? d) {
  if (d == null) return '';
  final days = DateTime.now().difference(d).inDays;
  if (days <= 0) return 'Today';
  if (days == 1) return 'Yesterday';
  if (days < 7) return '$days days ago';
  if (days < 30) return '${(days / 7).floor()} weeks ago';
  return formatDateLabel(d);
}

IconData iconForType(String type) {
  final t = type.toLowerCase();
  if (t.contains('house') || t.contains('villa')) return Icons.house_rounded;
  if (t.contains('flat') || t.contains('apartment')) {
    return Icons.apartment_rounded;
  }
  if (t.contains('hostel') || t.contains('room')) return Icons.bed_rounded;
  if (t.contains('office')) return Icons.business_rounded;
  if (t.contains('shop')) return Icons.storefront_rounded;
  if (t.contains('plot') || t.contains('land')) return Icons.landscape_rounded;
  if (t.contains('portion') || t.contains('floor')) return Icons.layers_rounded;
  return Icons.home_work_rounded;
}

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}

int _parseInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
}

String _numLabel(num? v) {
  if (v == null) return '';
  if (v == v.roundToDouble()) return v.toInt().toString();
  return v.toString();
}

/// One listing from GET /listings or GET /listings/{id}.
class ApiListing {
  const ApiListing({
    required this.id,
    required this.title,
    required this.isRent,
    required this.price,
    required this.propertyType,
    required this.city,
    required this.society,
    required this.areaValueLabel,
    required this.sizeLabel,
    required this.beds,
    required this.baths,
    required this.description,
    required this.amenities,
    required this.coverImageUrl,
    required this.imageUrls,
    required this.sellerName,
    required this.sellerVerified,
    required this.sellerAvatarUrl,
    required this.publishedAt,
    required this.views,
    required this.status,
    required this.contactName,
  });

  final String id;
  final String title;
  final bool isRent;
  final int price;
  final String propertyType;
  final String city;
  final String society;
  final String areaValueLabel; // society/area shown before the city
  final String sizeLabel;
  final int beds;
  final int baths;
  final String description;
  final List<String> amenities;
  final String? coverImageUrl;
  final List<String> imageUrls;
  final String sellerName;
  final bool sellerVerified;
  final String? sellerAvatarUrl;
  final DateTime? publishedAt;
  final int views;
  final String status;
  final String contactName;

  factory ApiListing.fromJson(Map<String, dynamic> j) {
    final attrs = (j['attributes'] as Map<String, dynamic>?) ?? {};
    final user = (j['user'] as Map<String, dynamic>?) ?? {};
    final society = attrs['society']?.toString() ?? '';
    final subArea = attrs['subArea']?.toString() ?? '';
    final areaLabel = society.isNotEmpty
        ? society
        : (subArea.isNotEmpty
              ? subArea
              : (j['cityZone']?.toString() ?? j['city']?.toString() ?? ''));
    final areaValue = j['areaValue'] is num
        ? (j['areaValue'] as num)
        : num.tryParse(j['areaValue']?.toString() ?? '');
    final areaUnit = j['areaUnit']?.toString() ?? '';
    final amenities = <String>[
      for (final a in (attrs['amenities'] as List? ?? [])) a.toString(),
      for (final a in (attrs['customAmenities']?.toString() ?? '').split(','))
        if (a.trim().isNotEmpty) a.trim(),
    ];
    final images = <String>[
      for (final im in (j['images'] as List? ?? []))
        if (im is Map && im['url'] != null) im['url'].toString(),
    ];
    final stats = (j['stats'] as Map<String, dynamic>?) ?? {};
    return ApiListing(
      id: j['id']?.toString() ?? '',
      title: j['title']?.toString() ?? 'Property',
      isRent: j['intent']?.toString() == 'rent',
      price: _parseInt(j['price']),
      propertyType: j['propertyType']?.toString() ?? '',
      city: j['city']?.toString() ?? '',
      society: society,
      areaValueLabel: areaLabel,
      sizeLabel: areaValue == null
          ? '—'
          : '${_numLabel(areaValue)} $areaUnit'.trim(),
      beds: _parseInt(j['bedrooms']),
      baths: _parseInt(j['bathrooms']),
      description: j['description']?.toString() ?? '',
      amenities: amenities,
      coverImageUrl: j['coverImageUrl']?.toString(),
      imageUrls: images,
      sellerName: user['fullName']?.toString() ?? 'Owner',
      sellerVerified: user['isVerified'] == true,
      sellerAvatarUrl: user['avatarUrl']?.toString(),
      publishedAt: _parseDate(j['publishedAt'] ?? j['createdAt']),
      views: _parseInt(stats['views']),
      status: j['constructionStatus']?.toString() ?? '—',
      contactName: j['contactName']?.toString() ?? '',
    );
  }

  /// Converts to the app's Property model used by all screens.
  Property toProperty() {
    final images = imageUrls.isNotEmpty
        ? imageUrls
        : [if (coverImageUrl != null) coverImageUrl!];
    return Property(
      id: id,
      title: title,
      priceLabel: formatPriceLabel(price, isRent: isRent),
      priceValue: price,
      isRent: isRent,
      type: propertyType,
      area: areaValueLabel,
      city: city,
      sizeLabel: sizeLabel,
      beds: beds,
      baths: baths,
      postedLabel: formatPostedLabel(publishedAt),
      status: status,
      description: description,
      sellerName: sellerName,
      sellerType: sellerVerified ? 'Verified Owner' : 'Property Owner',
      sellerRating: 0,
      sellerJoined: '—',
      phoneMasked: '+92 XXX XXX XXXX',
      phoneFull: '',
      icon: iconForType(propertyType),
      photoCount: images.isEmpty ? 1 : images.length,
      amenities: amenities,
      addedDate: formatDateLabel(publishedAt),
      views: views,
      imageUrls: images,
      sellerAvatarUrl: sellerAvatarUrl,
    );
  }
}

/// A popular city from GET /locations/popular-cities.
class PopularCity {
  const PopularCity({
    required this.name,
    required this.areas,
    required this.countLabel,
    required this.imageUrl,
    required this.listingCount,
  });

  final String name;
  final String areas;
  final String countLabel;
  final String imageUrl;
  final int listingCount;

  factory PopularCity.fromJson(Map<String, dynamic> j) {
    return PopularCity(
      name: j['name']?.toString() ?? '',
      areas: j['areas']?.toString() ?? '',
      countLabel: j['count']?.toString() ?? '',
      imageUrl: SiteAssets.absolute(j['image']?.toString() ?? ''),
      listingCount: _parseInt(j['listingCount']),
    );
  }
}

/// One Top Search link from GET /settings/public.
class TopSearchItem {
  const TopSearchItem({required this.label, required this.href});
  final String label;
  final String href;
}

/// Public site settings from GET /settings/public.
class PublicSettings {
  const PublicSettings({
    required this.helplinePhone,
    required this.supportEmail,
    required this.whatsappNumber,
    required this.topSearches,
  });

  final String helplinePhone;
  final String supportEmail;
  final String whatsappNumber;
  final List<TopSearchItem> topSearches;

  factory PublicSettings.fromJson(Map<String, dynamic> j) {
    final s = (j['settings'] as Map<String, dynamic>?) ?? j;
    return PublicSettings(
      helplinePhone: s['helplinePhone']?.toString() ?? '+92 51 889 4427',
      supportEmail: s['supportEmail']?.toString() ?? 'support@yubko.com',
      whatsappNumber: s['whatsappNumber']?.toString() ?? '',
      topSearches: [
        for (final t in (s['topSearches'] as List? ?? []))
          if (t is Map && t['isActive'] != false)
            TopSearchItem(
              label: t['label']?.toString() ?? '',
              href: t['href']?.toString() ?? '/properties',
            ),
      ],
    );
  }
}

/// A roommate listing from GET /roommates, mapped tolerantly onto
/// the app's RoommateProfile model (the API's exact field set is
/// still growing; unknown fields fall back to safe defaults).
RoommateProfile roommateFromJson(Map<String, dynamic> j) {
  final user = (j['user'] as Map<String, dynamic>?) ?? {};
  final name = (j['name'] ?? user['fullName'] ?? j['title'] ?? 'Roommate')
      .toString();
  final budget = _parseInt(j['budget'] ?? j['rent']);
  final purposeRaw = (j['purpose'] ?? j['type'] ?? '').toString().toLowerCase();
  return RoommateProfile(
    name: name,
    title: (j['title'] ?? 'Looking for a roommate').toString(),
    city: (j['city'] ?? '').toString(),
    area: (j['area'] ?? j['society'] ?? '').toString(),
    budgetLabel: budget > 0 ? 'PKR ${_thousands(budget)} / mo' : 'Budget n/a',
    budgetValue: budget,
    nonSmoker: j['nonSmoker'] == true || j['smokingAllowed'] == false,
    roomType: (j['roomType'] ?? 'Shared Room').toString(),
    gender: (j['gender'] ?? 'Any').toString(),
    purpose: (purposeRaw.contains('have') || purposeRaw.contains('offer'))
        ? 'Have Room'
        : 'Need Room',
    postedLabel: formatPostedLabel(_parseDate(j['createdAt'])),
    initial: name.isEmpty ? 'R' : name[0].toUpperCase(),
    views: _parseInt(j['views']),
  );
}
