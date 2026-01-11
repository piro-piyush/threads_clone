import 'package:get/get.dart';
import 'package:thread_clone/models/reply_model.dart';
import 'package:thread_clone/utils/mixins/supabase_mixin.dart';
import 'package:thread_clone/utils/query_generator.dart';

/// Service to manage comments (replies) for threads.
///
/// Handles CRUD operations and increments/decrements comment counts via Supabase RPC.
class CommentsService extends GetxService with SupabaseMixin {
  static const String table = 'comments';

  /// Singleton instance
  static CommentsService get instance => Get.find<CommentsService>();

  // ---------------- ADD COMMENT ----------------
  /// Adds a new comment to a thread and increments the thread's comment count.
  Future<void> addComment({
    required String threadId,
    required String content,
  }) async {
    if (!isLoggedIn) throw Exception("User not logged in");

    await insertRow(table, {
      'thread_id': threadId,
      'replied_by': uid,
      'content': content,
      'is_edited': false,
    });

    // Increment comment count on the thread
    await supabase.rpc(
      'comment_increment',
      params: {'count': 1, 'row_id': threadId},
    );
  }

  // ---------------- FETCH THREAD COMMENTS ----------------
  /// Fetch all comments for a given thread, including likes and thread info.
  Future<List<ReplyModel>> fetchComments(String threadId) async {
    final res = await supabase
        .from(table)
        .select(QueryGenerator.replyWithThreadAndLikes)
        .eq('thread_id', threadId)
        .order('created_at', ascending: true);

    return (res as List<dynamic>).map((e) => ReplyModel.fromJson(e)).toList();
  }

  // ---------------- DELETE COMMENT ----------------
  /// Deletes a comment and decrements the thread's comment count.
  Future<void> deleteComment(String commentId, String threadId) async {
    if (!isLoggedIn) throw Exception("User not logged in");

    await deleteRow(table, whereColumn: 'id', whereValue: commentId);

    await supabase.rpc(
      'comment_decrement',
      params: {'count': 1, 'row_id': threadId},
    );
  }

  // ---------------- UPDATE COMMENT ----------------
  /// Updates an existing comment and marks it as edited.
  Future<void> updateComment({
    required String commentId,
    required String content,
  }) async {
    if (!isLoggedIn) throw Exception("User not logged in");

    await updateRow(
      table,
      whereColumn: 'id',
      whereValue: commentId,
      data: {
        'content': content,
        'is_edited': true,
        'updated_at': DateTime.now().toIso8601String(),
      },
    );
  }

  // ---------------- FETCH USER REPLIES ----------------
  /// Fetch all replies made by a specific user.
  Future<List<ReplyModel>> fetchReplies(String userId) async {
    final List<dynamic> data = await supabase
        .from(table)
        .select(QueryGenerator.replyWithThreadAndLikes)
        .eq("replied_by", userId)
        .order("id", ascending: false);

    return data.map((e) => ReplyModel.fromJson(e)).toList();
  }
}
