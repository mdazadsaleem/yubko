import 'package:get/get.dart';

import '../services/catalog_service.dart';
import 'session_controller.dart';

/// GetX controller for Saved Homes (favourites).
///
/// The same observable heart state is shared by Home, Search,
/// Property Detail, Seller Profile, My Ads and the Saved tab:
/// tap a heart anywhere and every screen updates. It starts
/// EMPTY on purpose — a property becomes a favourite only when
/// the user taps its heart, never pre-selected. For signed-in
/// users the hearts also sync with the API wishlist.
class SavedController extends GetxController {
  static SavedController get to => Get.find<SavedController>();

  /// IDs of the properties the user has saved. Observe with Obx.
  final RxSet<String> ids = <String>{}.obs;

  bool contains(String propertyId) => ids.contains(propertyId);

  void toggle(String propertyId) {
    if (!ids.remove(propertyId)) {
      ids.add(propertyId);
    }
    // Signed-in users: keep the server wishlist in sync too
    // (the website does the same via POST /wishlist/toggle).
    try {
      if (SessionController.to.isLoggedIn) {
        CatalogService.toggleWishlist(propertyId);
      }
    } catch (_) {
      // Controller not registered (tests) — local-only is fine.
    }
  }

  /// Loads the signed-in user's wishlist IDs from the API.
  /// Guests keep their local hearts only.
  Future<void> syncFromServer() async {
    try {
      if (!SessionController.to.isLoggedIn) return;
      final serverIds = await CatalogService.fetchWishlistIds();
      ids.assignAll(serverIds.toSet());
    } catch (_) {
      // Offline or not signed in — keep the local state.
    }
  }

  /// Clears local favourites (used on logout).
  void resetLocal() => ids.clear();
}
