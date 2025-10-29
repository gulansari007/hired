import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';

void checkForFlexibleUpdate() async {
  try {
    final updateInfo = await InAppUpdate.checkForUpdate();
    if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
      // 👇 Show GetX dialog when update is available
      Get.defaultDialog(
        title: "Update Available",
        middleText: "A new version is ready to install.",
        textConfirm: "Update",
        textCancel: "Later",
        onConfirm: () async {
          Get.back(); // Close dialog
          try {
            await InAppUpdate.startFlexibleUpdate();
            await InAppUpdate.completeFlexibleUpdate();

            Get.snackbar(
              "Update Complete",
              "App updated successfully",
              snackPosition: SnackPosition.BOTTOM,
            );
          } catch (e) {
            Get.snackbar(
              "Update Failed",
              e.toString(),
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
      );
    }
  } catch (e) {
    print('Update check failed: $e');
  }
}
