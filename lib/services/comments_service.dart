import 'package:get/get.dart';
import 'package:thread_clone/models/reply_model.dart';
import 'package:thread_clone/utils/mixins/supabase_mixin.dart';

class CommentsService extends GetxService with SupabaseMixin {
  static const String table = 'comments';

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
      'is_deleted': false,
      'is_edited': false,
    });

    await supabase.rpc(
      'comment_increment',
      params: {'count': 1, 'row_id': threadId},
    );
  }

  // ---------------- FETCH THREAD COMMENTS ----------------
  Future<List<Map<String, dynamic>>> fetchComments(String threadId) async {
    final res = await supabase
        .from(table)
        .select('''
          id,
          content,
          created_at,
          user:replied_by (
            email,
            metadata
          )
        ''')
        .eq('thread_id', threadId)
        .eq('is_deleted', false)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(res);
  }

  // ---------------- DELETE COMMENT (SOFT) ----------------
  Future<void> deleteComment(String commentId) async {
    if (!isLoggedIn) throw Exception("User not logged in");

    await updateRow(
      table,
      whereColumn: 'id',
      whereValue: commentId,
      data: {'is_deleted': true},
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

  Future<List<ReplyModel>> fetchReplies() async {
    final List<dynamic> data = await supabase
        .from(table)
        .select('''
          id ,
          content ,
          created_at ,
          
          user:replied_by (email , metadata),
          thread:thread_id (
           id,
          content,
          image,
          posted_by,
          created_at,
          updated_at,
          likes,
          comments,
          allow_replies,
          user:posted_by (email, metadata)
            )
''')
        .eq("replied_by", uid!)
        .eq("is_deleted", false)
        .order("id", ascending: false);
    print(data.toString());
    return data.map((e) => ReplyModel.fromJson(e)).toList();
  }
}
