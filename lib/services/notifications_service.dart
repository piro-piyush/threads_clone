import 'package:get/get.dart';
import 'package:thread_clone/utils/mixins/supabase_mixin.dart';
import 'package:thread_clone/utils/query_generator.dart';

/// Service to manage notifications: send, fetch, mark read, and delete.
class NotificationsService extends GetxService with SupabaseMixin {
  static const String table = 'notifications';
  static NotificationsService get instance => Get.find<NotificationsService>();

  // ---------------- SEND NOTIFICATION ----------------
  /// Sends a notification to another user.
  ///
  /// [toUserId] - ID of the user receiving the notification
  /// [threadId] - Optional thread ID associated with the notification
  /// [content] - Notification message
  /// [type] - Type of notification (like, comment, etc.)
  Future<void> sendNotification({
    required String toUserId,
    String? threadId,
    required String content,
    required String type,
  }) async {
    try {
      if (!isLoggedIn) throw Exception("User not logged in");

      // Prevent sending notifications to self
      if (toUserId == uid) return;

      await insertRow(table, {
        'from_user_id': uid,
        'to_user_id': toUserId,
        'thread_id': threadId,
        'content': content,
        'type': type,
        'has_read': false,
        'is_deleted': false,
      });
    } catch (e) {
      Get.log('SendNotification Error: $e');
      Get.snackbar('Error', 'Failed to send notification');
    }
  }

  // ---------------- FETCH NOTIFICATIONS ----------------
  /// Fetches all active notifications for the current user
  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    try {
      final res = await supabase
          .from(table)
          .select(QueryGenerator.notification)
          .eq('to_user_id', uid!)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      Get.log('FetchNotifications Error: $e');
      return [];
    }
  }

  // ---------------- MARK AS READ ----------------
  /// Marks a single notification as read
  Future<void> markAsRead(String notificationId) async {
    await updateRow(
      table,
      whereColumn: 'id',
      whereValue: notificationId,
      data: {
        'has_read': true,
        'updated_at': DateTime.now().toIso8601String(),
      },
    );
  }

  // ---------------- MARK ALL AS READ ----------------
  /// Marks all notifications for the current user as read
  Future<void> markAllAsRead() async {
    await supabase
        .from(table)
        .update({
      'has_read': true,
      'updated_at': DateTime.now().toIso8601String(),
    })
        .eq('to_user_id', uid!)
        .eq('is_deleted', false);
  }

  // ---------------- DELETE NOTIFICATION (SOFT DELETE) ----------------
  /// Soft deletes a notification
  Future<void> deleteNotification(String notificationId) async {
    await updateRow(
      table,
      whereColumn: 'id',
      whereValue: notificationId,
      data: {
        'is_deleted': true,
        'updated_at': DateTime.now().toIso8601String(),
      },
    );
  }
}
