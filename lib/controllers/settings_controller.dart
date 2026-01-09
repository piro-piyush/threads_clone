import 'package:get/get.dart';

class SettingsController extends GetxController {
  var isPrivate = false.obs;
  var allowDMs = true.obs;
  var showActivityStatus = true.obs;
  var allowMentions = true.obs;

  void setPrivate(bool val) => isPrivate.value = val;

  void setAllowDMs(bool val) => allowDMs.value = val;

  void setShowActivityStatus(bool val) => showActivityStatus.value = val;

  void setAllowMentions(bool val) => allowMentions.value = val;

  void saveSettings() {
    // TODO: call Supabase / API to save these settings
    Get.snackbar("Success", "Privacy settings saved");
  }
}
