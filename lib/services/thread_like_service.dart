import 'package:get/get.dart';
import 'package:thread_clone/utils/mixins/supabase_mixin.dart';

/// Service to handle liking/unliking threads with Supabase integration.
class ThreadLikeService extends GetxService with SupabaseMixin {
  static ThreadLikeService get instance => Get.find<ThreadLikeService>();

  static const String table = 'likes';

  /// Reactive map to store like status for threads locally.
  RxMap<int, bool> likesMap = <int, bool>{}.obs;

  // ---------------- LIKE THREAD ----------------

  /// Likes a thread.
  ///
  /// Performs a check to prevent duplicate likes and increments the
  /// thread's like count atomically via a Supabase RPC.
  Future<void> likeThread(String threadId) async {
    if (!isLoggedIn || uid == null) return;

    try {
      final alreadyLiked = await isThreadLiked(threadId);
      if (alreadyLiked) return;

      await insertRow(table, {'thread_id': threadId, 'user_id': uid});

      await supabase.rpc(
        'likes_increment',
        params: {'count': 1, 'row_id': threadId},
      );
    } catch (e, st) {
      Get.log('LikeThread Error: $e\n$st');
      rethrow;
    }
  }

  // ---------------- UNLIKE THREAD ----------------

  /// Unlikes a thread and decrements the like count atomically.
  Future<void> unlikeThread(String threadId) async {
    if (!isLoggedIn || uid == null) return;

    try {
      await supabase
          .from(table)
          .delete()
          .eq('thread_id', threadId)
          .eq('user_id', uid!);

      await supabase.rpc(
        'likes_decrement',
        params: {'count': 1, 'row_id': threadId},
      );
    } catch (e, st) {
      Get.log('UnlikeThread Error: $e\n$st');
      rethrow;
    }
  }

  // ---------------- CHECK IF LIKED ----------------

  /// Checks if the current user has liked the given thread.
  Future<bool> isThreadLiked(String threadId) async {
    if (!isLoggedIn || uid == null) return false;

    final res = await supabase
        .from(table)
        .select('id')
        .eq('thread_id', threadId)
        .eq('user_id', uid!)
        .maybeSingle();

    return res != null;
  }
}
