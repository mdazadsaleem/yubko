import 'package:get/get.dart';

/// GetX controller for Saved Homes (favourites).
///
/// The same observable heart state is shared by Home, Search,
/// Property Detail, Seller Profile, My Ads and the Saved tab:
/// tap a heart anywhere and every screen updates. It starts
/// EMPTY on purpose — a property becomes a favourite only when
/// the user taps its heart, never pre-selected.
class SavedController extends GetxController {
  static SavedController get to => Get.find<SavedController>();

  /// IDs of the properties the user has saved. Observe with Obx.
  final RxSet<String> ids = <String>{}.obs;

  bool contains(String propertyId) => ids.contains(propertyId);

  void toggle(String propertyId) {
    if (!ids.remove(propertyId)) {
      ids.add(propertyId);
    }
  }
}
