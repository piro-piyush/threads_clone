import 'dart:io';
import 'package:get/get.dart';
import 'package:thread_clone/models/thread_model.dart';
import 'package:thread_clone/utils/mixins/supabase_mixin.dart';

class ThreadsService extends GetxService with SupabaseMixin {
  static const String table = 'threads';

  // ---------------- CREATE THREAD ----------------
  Future<void> createThread({
    required String content,
    String? image,
    bool allowReplies = true,
  }) async {
    if (!isLoggedIn) throw Exception("User not logged in");

    await insertRow(table, {
      'posted_by': uid,
      'content': content,
      'image': image,
      'allow_replies': allowReplies,
      'likes': [],
      'is_archived': false,
      'is_edited': false,
    });
  }

  // ---------------- FETCH FEED ----------------
  Future<List<ThreadModel>> fetchThreads() async {
    try {
      final res = await supabase
          .from(table)
          .select('''
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
      ''')

          .order('created_at', ascending: false);

      return (res as List)
          .map((e) => ThreadModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      Get.log('FetchThreads Error: $e');
      return [];
    }
  }

  // ---------------- FETCH SINGLE THREAD ----------------
  Future<ThreadModel> fetchThread(String id) async {
    final data = await getRow(
      table,
      whereColumn: 'id',
      whereValue: id,
      select: '''
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
      ''',
    );

    if (data == null) {
      throw Exception('Thread not found');
    }

    return ThreadModel.fromJson(data);
  }

  // ---------------- UPDATE THREAD ----------------
  Future<void> updateThread({
    required String threadId,
    required String content,
  }) async {
    await updateRow(
      table,
      whereColumn: 'id',
      whereValue: threadId,
      data: {
        'content': content,
        'is_edited': true,
        'updated_at': DateTime.now().toIso8601String(),
      },
    );
  }

  // ---------------- ARCHIVE THREAD ----------------
  Future<void> archiveThread(String threadId) async {
    await updateRow(
      table,
      whereColumn: 'id',
      whereValue: threadId,
      data: {'is_archived': true},
    );
  }

  // ---------------- DELETE THREAD (SOFT) ----------------
  Future<void> deleteThread(String threadId) async {
    await deleteRow(
      table,
      whereColumn: 'id',
      whereValue: threadId,
    );
  }

  // ---------------- UPLOAD THREAD IMAGE ----------------
  Future<String> uploadThreadImage({
    required File file,
    required String bucket,
  }) async {
    if (!isLoggedIn) throw Exception("User not logged in");

    return uploadImage(file: file, bucket: bucket, folder: 'threads/$uid');
  }

  // ---------------- LIKE THREAD ----------------
  Future<void> like(String threadId) async {
    if (!isLoggedIn) return;

    try {
      // Fetch current likes
      final res = await supabase
          .from('threads')
          .select('likes')
          .eq('id', threadId)
          .maybeSingle(); // safer than .single(), returns null if not found

      if (res == null) {
        Get.snackbar('Error', 'Thread not found');
        return;
      }

      // Ensure likes is a List<String>
      final List<dynamic> currentLikes = res['likes'] ?? [];
      final List<String> likes = currentLikes.map((e) => e.toString()).toList();

      if (likes.contains(uid)) return; // already liked

      likes.add(uid!);

      // Update thread likes
      await supabase
          .from('threads')
          .update({'likes': likes})
          .eq('id', threadId);
    } catch (e, st) {
      Get.log('Like Error: $e\n$st');
      Get.snackbar('Error', 'Failed to like thread');
    }
  }

  // ---------------- UNLIKE THREAD ----------------
  Future<void> unlike(String threadId) async {
    if (!isLoggedIn) return;

    try {
      final res = await supabase
          .from('threads')
          .select('likes')
          .eq('id', threadId)
          .single();

      final List likes = res['likes'] ?? [];

      if (!likes.contains(uid)) return;

      likes.remove(uid);

      await supabase
          .from('threads')
          .update({'likes': likes})
          .eq('id', threadId);
    } catch (e) {
      Get.log('Unlike Error: $e');
      Get.snackbar('Error', 'Failed to unlike thread');
    }
  }



  // ---------------- FETCH CURRENT USER THREADS ----------------
  Future<List<ThreadModel>> fetchMyThreads() async {
    if (!isLoggedIn) return [];

    try {
      final res = await supabase
          .from(table)
          .select('''
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
        ''')
          .eq('posted_by', uid!)

          .order('created_at', ascending: false);

      return (res as List)
          .map((e) => ThreadModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      Get.log('FetchMyThreads Error: $e');
      return [];
    }
  }
}
