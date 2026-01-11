import 'package:get/get.dart';
import 'package:thread_clone/models/notification_model.dart';
import 'package:thread_clone/services/notifications_service.dart';

/// NotificationsController manages user notifications.
///
/// Responsibilities:
/// - Fetching notifications from backend
/// - Managing loading state
/// - Exposing reactive notification list for UI
///
/// Architecture:
/// - Uses GetX for state management
/// - Delegates data fetching to NotificationsService
class NotificationsController extends GetxController {
  // ---------------- SERVICES ----------------

  /// Handles notifications-related API calls
  final NotificationsService _notificationsService =
  Get.find<NotificationsService>();

  // ---------------- STATE ----------------

  /// List of notifications displayed in UI
  final RxList<NotificationModel> notifications =
      <NotificationModel>[].obs;

  /// Loading indicator for initial fetch
  final RxBool isLoading = false.obs;

  // ---------------- LIFECYCLE ----------------

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  // ---------------- INIT ----------------

  /// Initializes notifications feed
  Future<void> initialize() async {
    isLoading.value = true;
    await fetchNotifications();
    isLoading.value = false;
  }

  // ---------------- FETCH ----------------

  /// Fetches notifications for the current user
  Future<void> fetchNotifications() async {
    final fetchedData =
    await _notificationsService.fetchNotifications();

    notifications.value = fetchedData
        .map((e) => NotificationModel.fromJson(e))
        .toList();
  }
}
