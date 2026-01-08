import 'package:get/get.dart';
import 'package:thread_clone/utils/mixins/supabase_mixin.dart';
import 'dart:io';

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
      'is_deleted': false,
      'is_archived': false,
      'is_edited': false,
    });
  }

  // ---------------- FETCH FEED ----------------
  Future<List<Map<String, dynamic>>> fetchFeed({
    int limit = 20,
  }) async {
    return fetchList(
      table,
      orderBy: 'created_at',
      ascending: false,
      limit: limit,
      filters: {
        'is_deleted': false,
        'is_archived': false,
      },
    );
  }

  // ---------------- FETCH USER THREADS ----------------
  Future<List<Map<String, dynamic>>> fetchUserThreads(String userId) async {
    return fetchList(
      table,
      orderBy: 'created_at',
      ascending: false,
      filters: {
        'posted_by': userId,
        'is_deleted': false,
      },
    );
  }

  // ---------------- UPDATE THREAD ----------------
  Future<void> updateThread({
    required int threadId,
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
  Future<void> archiveThread(int threadId) async {
    await updateRow(
      table,
      whereColumn: 'id',
      whereValue: threadId,
      data: {
        'is_archived': true,
      },
    );
  }

  // ---------------- DELETE THREAD (SOFT DELETE) ----------------
  Future<void> deleteThread(int threadId) async {
    await updateRow(
      table,
      whereColumn: 'id',
      whereValue: threadId,
      data: {
        'is_deleted': true,
      },
    );
  }

  // ---------------- UPLOAD THREAD IMAGE ----------------
  Future<String> uploadThreadImage({
    required File file,
    required String bucket,
  }) async {
    if (!isLoggedIn) throw Exception("User not logged in");

    return uploadImage(
      file: file,
      bucket: bucket,
      folder: 'threads/$uid',
    );
  }
}
