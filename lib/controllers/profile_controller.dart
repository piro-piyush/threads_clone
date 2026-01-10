import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thread_clone/models/reply_model.dart';
import 'package:thread_clone/models/thread_model.dart';
import 'package:thread_clone/services/comments_service.dart';
import 'package:thread_clone/services/notifications_service.dart';
import 'package:thread_clone/services/thread_like_service.dart';
import 'package:thread_clone/services/threads_service.dart';
import 'package:thread_clone/services/user_service.dart';
import 'package:thread_clone/utils/enums.dart';
import 'package:thread_clone/utils/helper.dart';
import 'package:thread_clone/utils/thread_event.dart';

class ProfileController extends GetxController {
  final ThreadsService threadsService = Get.find<ThreadsService>();
  final CommentsService commentsService = Get.find<CommentsService>();
  final ThreadLikeService threadLikeService = Get.find<ThreadLikeService>();
  final UserService userService = Get.find<UserService>();
  final NotificationsService _notificationsService =
      Get.find<NotificationsService>();

  // ---------------- STATE ----------------
  final RxList<ThreadModel> myThreads = <ThreadModel>[].obs;
  final RxList<ReplyModel> repliedThreads = <ReplyModel>[].obs;

  final RxBool isThreadsLoading = false.obs;
  final RxBool isRepliesLoading = false.obs;

  String get uid => threadsService.currentUser!.id;

  RxMap<int, bool> get likesMap => threadLikeService.likesMap;
  late final StreamSubscription<ThreadEvent> _threadSubscription;

  Future<bool> Function(String threadId) get isThreadLiked =>
      threadLikeService.isThreadLiked;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  // ---------------- INIT PROFILE DATA ----------------

  Future<void> initialize() async {
    try {
      await threadsService.startListening();
      _threadSubscription = threadsService.stream.listen(_handleThreadEvent);

      await Future.wait([fetchMyThreads(), fetchRepliedThreads()]);
    } catch (e) {
      Get.log('HomeController Error: $e');
    }
  }

  // ---------------- REALTIME EVENTS ----------------
  /// Handles realtime insert/update/delete events
  void _handleThreadEvent(ThreadEvent event) {
    switch (event.type) {
      case ThreadEventType.insert:
        // My Threads
        if (event.thread?.user.id == uid) {
          myThreads.insert(0, event.thread!);
          fillLikesMap([event.thread!]);
        }

        // Replied Threads (optional insert not needed)
        break;

      case ThreadEventType.update:
        // Update in My Threads
        final myIndex = myThreads.indexWhere((t) => t.id == event.thread?.id);
        if (myIndex != -1) {
          myThreads[myIndex] = event.thread!;
        }

        // Update embedded thread inside replies
        for (int i = 0; i < repliedThreads.length; i++) {
          if (repliedThreads[i].thread.id == event.thread?.id) {
            repliedThreads[i] = repliedThreads[i].copyWith(
              thread: event.thread!,
            );
          }
        }
        break;

      case ThreadEventType.delete:
        // Remove from My Threads
        myThreads.removeWhere((t) => t.id == event.threadId);

        // Remove replies whose thread got deleted
        repliedThreads.removeWhere((r) => r.thread.id == event.threadId);
        break;
    }
  }

  Future<void> fillLikesMap(List<ThreadModel> threads) async {
    await Future.wait(
      threads.map((thread) async {
        likesMap[thread.id] ??= await threadLikeService.isThreadLiked(
          thread.id.toString(),
        );
      }),
    );
  }

  // ---------------- FETCH MY THREADS ----------------
  Future<void> fetchMyThreads() async {
    try {
      isThreadsLoading.value = true;
      myThreads.clear();

      final threads = await threadsService.fetchThreads(uid);
      myThreads.value = threads;
      fillLikesMap(threads);
    } catch (e) {
      Get.log('fetchMyThreads Error: $e');
      myThreads.clear();
    } finally {
      isThreadsLoading.value = false;
    }
  }

  // ---------------- FETCH THREADS USER REPLIED TO ----------------
  Future<void> fetchRepliedThreads() async {
    try {
      isRepliesLoading.value = true;

      // Get all comments by current user

      final commentsData = await commentsService.fetchReplies(uid);
      repliedThreads.value = commentsData;
      fillLikesMap(commentsData.map((comment) => comment.thread).toList());
    } catch (e) {
      Get.log('fetchRepliedThreads Error: $e');
      repliedThreads.clear();
    } finally {
      isRepliesLoading.value = false;
    }
  }

  void onLikeTapped(ThreadModel thread) async {
    if (!threadsService.isLoggedIn) return;

    final index = myThreads.indexWhere((t) => t.id == thread.id);
    if (index == -1) return;

    final currentThread = myThreads[index];
    final alreadyLiked = await threadLikeService.isThreadLiked(
      thread.id.toString(),
    );

    // 🔁 Local optimistic update
    final updatedThread = currentThread.copyWith(
      likesCount: alreadyLiked
          ? currentThread.likesCount - 1
          : currentThread.likesCount + 1,
    );

    myThreads[index] = updatedThread;
    // Optimistic update
    likesMap[thread.id] = !alreadyLiked;
    try {
      // 🔥 Server update
      if (alreadyLiked) {
        await threadLikeService.unlikeThread(thread.id.toString());
      } else {
        await threadLikeService.likeThread(thread.id.toString());

        // Send notification to thread owner
        if (thread.user.id != threadsService.uid) {
          await _notificationsService.sendNotification(
            toUserId: thread.user.id,
            threadId: thread.id.toString(),
            content: "Someone liked your thread.",
            // or NotificationType.like.description
            type: NotificationType.like.value,
          );
        }
      }
    } catch (e) {
      // ❌ Rollback on error
      myThreads[index] = currentThread;
      likesMap[thread.id] = alreadyLiked;
      Get.snackbar('Error', 'Failed to like thread');
    }
  }

  void onShareTapped(ThreadModel thread) {
    showSnackBar('Coming Soon', 'Share feature coming soon');
  }

  bool canEditThread(ThreadModel thread) {
    return thread.user.id == uid;
  }

  bool canDeleteThread(ThreadModel thread) {
    return thread.user.id == uid;
  }

  Future<void> editThread(ThreadModel thread) async {}

  Future<void> deleteThread(BuildContext context, ThreadModel thread) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete thread?'),
          content: const Text(
            'This thread will be permanently deleted. '
            'All replies and likes will be lost.',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      // 🔥 Soft delete thread
      await threadsService.deleteThread(thread.id.toString());
      myThreads.removeWhere((t) => t.id == thread.id);
      showSnackBar(
        'Thread Deleted',
        'Your thread has been deleted successfully',
      );
    } catch (e) {
      showSnackBar('Error', 'Failed to delete thread');
    }
  }

  Future<void> editReply(ReplyModel reply) async {}

  Future<void> deleteReply(BuildContext context, ReplyModel reply) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete reply?'),
          content: const Text(
            'This reply will be permanently deleted. '
            'You won’t be able to undo this action.',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;
    try {
      // 🔥 Call delete API here
      await commentsService.deleteComment(
        reply.id.toString(),
        reply.thread.id.toString(),
      );

      repliedThreads.removeWhere((t) => t.id == reply.id);

      // Optional UI feedback
      showSnackBar('Deleted', 'Your reply has been deleted');
    } catch (e) {
      showSnackBar('Error', 'Failed to delete thread');
    }
  }
}
