import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../data/api_listing.dart';
import '../data/dummy_data.dart';
import '../controllers/session_controller.dart';
import 'auth_service.dart';

/// The current JWT, when a session controller is registered.
String? get currentAuthToken {
  try {
    return SessionController.to.token;
  } catch (_) {
    return null;
  }
}

/// Client for the website's data APIs on server.yubko.com:
/// listings, categories, popular cities, public settings,
/// roommates, wishlist and contact reveal. These are the same
/// endpoints the yubko.com website itself calls (verified
/// 2026-11-07 against the live server).
class CatalogService {
  CatalogService._();

  static Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse(
      '${ApiConfig.apiBaseUrl}$path',
    ).replace(queryParameters: query);
  }

  static Map<String, String> _headers({bool auth = false}) => {
    'Accept': 'application/json',
    if (auth && currentAuthToken != null)
      'Authorization': 'Bearer $currentAuthToken',
  };

  static Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String>? query,
    bool auth = false,
  }) async {
    try {
      final response = await http
          .get(_uri(path, query), headers: _headers(auth: auth))
          .timeout(ApiConfig.timeout);
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw ApiException('Unexpected response from the server.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'Network error. Please check your internet connection.',
      );
    }
  }

  /// GET /listings — server-side filters verified live:
  /// intent (rent/sell), propertyType, city, society, minPrice,
  /// maxPrice, minBedrooms, sortBy (newest/price_asc/price_desc).
  static Future<(List<ApiListing>, int)> fetchListings({
    String? intent,
    String? propertyType,
    String? city,
    String? society,
    int? minPrice,
    int? maxPrice,
    int? minBedrooms,
    String sortBy = 'newest',
    int limit = 100,
  }) async {
    final body = await _get(
      '/listings',
      query: {
        if (intent != null) 'intent': intent,
        if (propertyType != null) 'propertyType': propertyType,
        if (city != null) 'city': city,
        if (society != null) 'society': society,
        if (minPrice != null) 'minPrice': '$minPrice',
        if (maxPrice != null) 'maxPrice': '$maxPrice',
        if (minBedrooms != null) 'minBedrooms': '$minBedrooms',
        'sortBy': sortBy,
        'page': '1',
        'limit': '$limit',
      },
    );
    final listings = [
      for (final l in (body['listings'] as List? ?? []))
        if (l is Map<String, dynamic>) ApiListing.fromJson(l),
    ];
    return (listings, (body['count'] as num?)?.toInt() ?? listings.length);
  }

  /// GET /listings/{id} — full detail incl. images and stats.
  static Future<ApiListing> fetchListing(String id) async {
    final body = await _get('/listings/$id');
    final listing = body['listing'];
    if (listing is Map<String, dynamic>) return ApiListing.fromJson(listing);
    throw ApiException('Listing not found.');
  }

  /// GET /listings/mine — the signed-in user's own listings.
  static Future<List<ApiListing>> fetchMyListings() async {
    final body = await _get('/listings/mine', auth: true);
    return [
      for (final l
          in (body['listings'] as List? ?? body['data'] as List? ?? []))
        if (l is Map<String, dynamic>) ApiListing.fromJson(l),
    ];
  }

  /// GET /listings/counts/categories — ads per property type.
  static Future<Map<String, int>> fetchCategoryCounts() async {
    final body = await _get('/listings/counts/categories');
    final data = (body['data'] as Map<String, dynamic>?) ?? {};
    return {
      for (final e in data.entries) e.key: (e.value as num?)?.toInt() ?? 0,
    };
  }

  /// GET /locations/popular-cities — featured city + the rest.
  static Future<List<PopularCity>> fetchPopularCities() async {
    final body = await _get('/locations/popular-cities');
    final cities = <PopularCity>[];
    final featured = body['featured'];
    if (featured is Map<String, dynamic>) {
      cities.add(PopularCity.fromJson(featured));
    }
    for (final c in (body['otherCities'] as List? ?? [])) {
      if (c is Map<String, dynamic>) cities.add(PopularCity.fromJson(c));
    }
    return cities;
  }

  /// GET /settings/public — helpline, support email, Top Searches.
  static Future<PublicSettings> fetchPublicSettings() async {
    final body = await _get('/settings/public');
    return PublicSettings.fromJson(body);
  }

  /// GET /roommates — the live roommate listings (may be empty).
  static Future<List<RoommateProfile>> fetchRoommates() async {
    final body = await _get('/roommates', query: {'limit': '100'});
    return [
      for (final r in (body['data'] as List? ?? []))
        if (r is Map<String, dynamic>) roommateFromJson(r),
    ];
  }

  /// POST /listings/{id}/contact-reveal — the owner's real number.
  static Future<({String mobile, String whatsapp, String name})> revealContact(
    String listingId,
  ) async {
    try {
      final response = await http
          .post(
            _uri('/listings/$listingId/contact-reveal'),
            headers: {'Content-Type': 'application/json', ..._headers()},
            body: '{}',
          )
          .timeout(ApiConfig.timeout);
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final c = (decoded['contact'] as Map<String, dynamic>?) ?? {};
        return (
          mobile: c['mobileNumber']?.toString() ?? '',
          whatsapp: c['whatsappNumber']?.toString() ?? '',
          name: c['contactName']?.toString() ?? '',
        );
      }
      throw ApiException('Could not reveal the number.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'Network error. Please check your internet connection.',
      );
    }
  }

  /// GET /wishlist/ids — the signed-in user's saved listing IDs.
  static Future<List<String>> fetchWishlistIds() async {
    final body = await _get('/wishlist/ids', auth: true);
    return [for (final id in (body['ids'] as List? ?? [])) id.toString()];
  }

  /// POST /wishlist/toggle — saves or unsaves a listing server-side.
  static Future<void> toggleWishlist(String listingId) async {
    try {
      await http
          .post(
            _uri('/wishlist/toggle'),
            headers: {
              'Content-Type': 'application/json',
              ..._headers(auth: true),
            },
            body: jsonEncode({'listingId': listingId}),
          )
          .timeout(ApiConfig.timeout);
    } catch (_) {
      // Best-effort sync; the next wishlist load reconciles.
    }
  }
}
