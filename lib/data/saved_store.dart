import 'package:flutter/foundation.dart';

/// Shared Saved Homes state.
///
/// The same heart state is used by Home, Search, Property Detail,
/// Seller Profile, My Ads and the Saved tab. It starts EMPTY on
/// purpose: a property becomes a favourite only when the user
/// taps its heart — never pre-selected.
class SavedStore {
  SavedStore._();

  static final ValueNotifier<Set<String>> ids = ValueNotifier<Set<String>>(
    <String>{},
  );

  static bool contains(String propertyId) => ids.value.contains(propertyId);

  static void toggle(String propertyId) {
    final next = {...ids.value};
    if (!next.add(propertyId)) {
      next.remove(propertyId);
    }
    ids.value = next;
  }
}
