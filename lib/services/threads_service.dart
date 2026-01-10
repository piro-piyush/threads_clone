import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:thread_clone/models/thread_model.dart';
import 'package:thread_clone/utils/enums.dart';
import 'package:thread_clone/utils/mixins/supabase_mixin.dart';
import 'package:thread_clone/utils/query_generator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thread_clone/utils/thread_event.dart';

class ThreadsService extends GetxService with SupabaseMixin {
  static const String table = 'threads';
  static ThreadsService get instance => Get.find<ThreadsService>();

  final _controller = StreamController<ThreadEvent>.broadcast();
  Stream<ThreadEvent> get stream => _controller.stream;

  RealtimeChannel? _channel;

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
      'is_archived': false,
      'is_edited': false,
    });
  }

  // ---------------- FETCH FEED ----------------
  Future<List<ThreadModel>> fetchFeed() async {
    try {
      final res = await supabase
          .from(table)
          .select(QueryGenerator.threadWithLikesAndUser)
          .order('created_at', ascending: false);

      return (res as List)
          .map((e) => ThreadModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      Get.log('FetchThreads Error: $e');
      return [];
    }
  }

  // ---------------- START LISTENING ----------------
  Future<void> startListening() async {
   try{
     _channel = supabase
         .channel('public:$table')

     // INSERT
         .onPostgresChanges(
       event: PostgresChangeEvent.insert,
       schema: 'public',
       table: table,
       callback: (payload) async {
         final data = payload.newRecord;

         final thread = await _fetchSingle(data['id']);
         _controller.add(
           ThreadEvent(
             type: ThreadEventType.insert,
             thread: thread,
           ),
         );
       },
     )

     // UPDATE
         .onPostgresChanges(
       event: PostgresChangeEvent.update,
       schema: 'public',
       table: table,
       callback: (payload) async {
         final data = payload.newRecord;
         final thread = await _fetchSingle(data['id']);
         _controller.add(
           ThreadEvent(
             type: ThreadEventType.update,
             thread: thread,
           ),
         );
       },
     )

     // DELETE
         .onPostgresChanges(
       event: PostgresChangeEvent.delete,
       schema: 'public',
       table: table,
       callback: (payload) {
         final data = payload.oldRecord;
         _controller.add(
           ThreadEvent(
             type: ThreadEventType.delete,
             threadId: data['id'],
           ),
         );
       },
     )
         .subscribe();
   }catch(e){
     Get.log('StartListening Error: $e');
   }
  }

  // ---------------- FETCH SINGLE THREAD ----------------
  Future<ThreadModel> _fetchSingle(dynamic id) async {
    final res = await supabase
        .from(table)
        .select(QueryGenerator.threadWithLikesAndUser)
        .eq('id', id)
        .single();

    return ThreadModel.fromJson(res);
  }

  // ---------------- STOP ----------------
  Future<void> stopListening() async {
    await _channel?.unsubscribe();
    await _controller.close();
  }



  // ---------------- FETCH SINGLE THREAD ----------------
  Future<ThreadModel> fetchThread(String id) async {
    final data = await getRow(
      table,
      whereColumn: 'id',
      whereValue: id,
      select: QueryGenerator.threadWithLikesAndUser,
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

  // ---------------- DELETE THREAD ----------------
  Future<void> deleteThread(String threadId) async {
    await deleteRow(table, whereColumn: 'id', whereValue: threadId);
  }

  // ---------------- UPLOAD THREAD IMAGE ----------------
  Future<String> uploadThreadImage({
    required File file,
    required String bucket,
  }) async {
    if (!isLoggedIn) throw Exception("User not logged in");

    return uploadImage(file: file, bucket: bucket, folder: 'threads/$uid');
  }

  // ---------------- FETCH MY THREADS ----------------
  Future<List<ThreadModel>> fetchThreads(String id) async {
    if (!isLoggedIn) return [];

    try {
      final res = await supabase
          .from(table)
          .select(QueryGenerator.threadWithLikesAndUser)
          .eq('posted_by', id)
          .order('created_at', ascending: false);

      return (res as List)
          .map((e) => ThreadModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      Get.log('FetchMyThreads Error: $e');
      return [];
    }
  }

  // ---------------- CLEANUP ----------------
  @override
  void onClose() {
    // _threadsController.close();
    stopListening();
    super.onClose();
  }
}
