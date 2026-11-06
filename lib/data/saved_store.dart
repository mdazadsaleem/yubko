import 'package:flutter/foundation.dart';

/// Shared Saved Homes state for the design phase.
///
/// The same heart state is used by Home, Search, Property Detail,
/// Seller Profile, My Ads and the Saved tab. In Phase 2 this is
/// replaced by the signed-in user's saved listings from the API.
class SavedStore {
  SavedStore._();

  static final ValueNotifier<Set<String>> ids = ValueNotifier<Set<String>>({
    'p1',
    'p3',
    'p7',
  });

  static bool contains(String propertyId) => ids.value.contains(propertyId);

  static void toggle(String propertyId) {
    final next = {...ids.value};
    if (!next.add(propertyId)) {
      next.remove(propertyId);
    }
    ids.value = next;
  }
}
