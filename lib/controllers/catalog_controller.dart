import 'package:get/get.dart';

import '../data/api_listing.dart';
import '../data/dummy_data.dart';
import '../services/catalog_service.dart';

/// GetX controller for the website's live catalogue data:
/// home listings, category counts, popular cities and the
/// public settings (helpline, support email, Top Searches).
/// Also keeps a cache of every Property the app has loaded, so
/// the Saved tab and seller pages can resolve listings by ID.
class CatalogController extends GetxController {
  static CatalogController get to => Get.find<CatalogController>();

  final Rxn<PublicSettings> settings = Rxn<PublicSettings>();
  final RxMap<String, int> categoryCounts = <String, int>{}.obs;
  final RxList<PopularCity> popularCities = <PopularCity>[].obs;
  final RxList<Property> homeListings = <Property>[].obs;
  final RxBool homeLoading = false.obs;
  final RxnString homeError = RxnString();

  /// Every property loaded from the API this session, by ID.
  final Map<String, Property> known = {};

  bool _homeLoaded = false;

  void register(Iterable<Property> properties) {
    for (final p in properties) {
      known[p.id] = p;
    }
  }

  /// Resolves a property by ID: API cache first, then samples.
  Property? lookup(String id) {
    final hit = known[id];
    if (hit != null) return hit;
    for (final p in dummyProperties) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// All properties the app can show for a seller: API + samples.
  List<Property> knownProperties() {
    final byId = <String, Property>{
      for (final p in dummyProperties) p.id: p,
      ...known,
    };
    return byId.values.toList();
  }

  Future<void> loadSettings() async {
    if (settings.value != null) return;
    try {
      settings.value = await CatalogService.fetchPublicSettings();
    } catch (_) {
      // Keep fallbacks; settings are not critical to browsing.
    }
  }

  Future<void> loadHome({bool force = false}) async {
    if (_homeLoaded && !force) return;
    homeLoading.value = true;
    homeError.value = null;
    try {
      final results = await Future.wait([
        CatalogService.fetchListings(limit: 6),
        CatalogService.fetchCategoryCounts(),
        CatalogService.fetchPopularCities(),
        CatalogService.fetchPublicSettings(),
      ]);
      final (listings, _) = results[0] as (List<ApiListing>, int);
      final properties = listings.map((l) => l.toProperty()).toList();
      homeListings.assignAll(properties);
      register(properties);
      categoryCounts.assignAll(results[1] as Map<String, int>);
      popularCities.assignAll(results[2] as List<PopularCity>);
      settings.value = results[3] as PublicSettings;
      _homeLoaded = true;
    } catch (e) {
      homeError.value = e.toString();
    } finally {
      homeLoading.value = false;
    }
  }

  /// Ads count for a category card, from per-type API counts.
  int categoryCount(List<String> types) {
    var total = 0;
    for (final t in types) {
      total += categoryCounts[t] ?? 0;
    }
    return total;
  }
}
