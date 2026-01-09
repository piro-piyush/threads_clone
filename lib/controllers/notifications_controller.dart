import 'package:get/get.dart';
import 'package:thread_clone/models/notification_model.dart';
import 'package:thread_clone/services/notifications_service.dart';

class NotificationsController extends GetxController {
  final NotificationsService _notificationsService =
      Get.find<NotificationsService>();
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    init();
  }

  void init() async {
    isLoading.value = true;
    await fetchNotifications();
    isLoading.value = false;
  }

  Future<void> fetchNotifications() async {
    final fetchedData = await _notificationsService.fetchNotifications();
    notifications.value = fetchedData
        .map((e) => NotificationModel.fromJson(e))
        .toList();
    print(fetchedData.toString());
  }
}
