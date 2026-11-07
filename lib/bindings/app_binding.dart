import 'package:get/get.dart';

import '../controllers/catalog_controller.dart';
import '../controllers/saved_controller.dart';
import '../controllers/session_controller.dart';

/// Registers the app's GetX controllers once at startup.
class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SessionController>(SessionController(), permanent: true);
    Get.put<SavedController>(SavedController(), permanent: true);
    Get.put<CatalogController>(CatalogController(), permanent: true);
  }
}
