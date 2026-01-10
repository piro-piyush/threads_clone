import 'package:get/get.dart';
import 'package:thread_clone/models/reply_model.dart';
import 'package:thread_clone/utils/mixins/supabase_mixin.dart';
import 'package:thread_clone/utils/query_generator.dart';

class CommentsService extends GetxService with SupabaseMixin {
  static const String table = 'comments';
  static CommentsService get instance => Get.find<CommentsService>();

  // ---------------- ADD COMMENT ----------------
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

    await supabase.rpc(
      'comment_increment',
      params: {'count': 1, 'row_id': threadId},
    );
  }

  // ---------------- FETCH THREAD COMMENTS ----------------
  Future<List<ReplyModel>> fetchComments(String threadId) async {
    final res = await supabase
        .from(table)
        .select(QueryGenerator.replyWithThreadAndLikes)
        .eq('thread_id', threadId)
        .order('created_at', ascending: true);

    return res.map((e) => ReplyModel.fromJson(e)).toList();
  }

  // ---------------- DELETE COMMENT (SOFT) ----------------
  Future<void> deleteComment(String commentId, String threadId) async {
    if (!isLoggedIn) throw Exception("User not logged in");

    await deleteRow(table, whereColumn: 'id', whereValue: commentId);
    await supabase.rpc(
      'comment_decrement',
      params: {'count': 1, 'row_id': threadId},
    );
  }

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

  Future<List<ReplyModel>> fetchReplies(String id) async {
    final List<dynamic> data = await supabase
        .from(table)
        .select(QueryGenerator.replyWithThreadAndLikes)
        .eq("replied_by", id)
        .order("id", ascending: false);
    return data.map((e) => ReplyModel.fromJson(e)).toList();
  }
}
