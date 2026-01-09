import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thread_clone/models/reply_model.dart';
import 'package:thread_clone/models/thread_model.dart';
import 'package:thread_clone/services/comments_service.dart';
import 'package:thread_clone/services/notifications_service.dart';
import 'package:thread_clone/services/threads_service.dart';
import 'package:thread_clone/utils/enums.dart';
import 'package:thread_clone/utils/helper.dart';

class ProfileController extends GetxController {
  final ThreadsService threadsService = Get.find<ThreadsService>();
  final CommentsService commentsService = Get.find<CommentsService>();
  final NotificationsService _notificationsService =
      Get.find<NotificationsService>();

  // ---------------- STATE ----------------
  final RxList<ThreadModel> myThreads = <ThreadModel>[].obs;
  final RxList<ReplyModel> repliedThreads = <ReplyModel>[].obs;

  final RxBool isThreadsLoading = false.obs;
  final RxBool isRepliesLoading = false.obs;

  String get uid => threadsService.currentUser!.id;

  @override
  void onInit() {
    super.onInit();
    initProfileData();
  }

  // ---------------- INIT PROFILE DATA ----------------
  Future<void> initProfileData() async {
    await Future.wait([fetchMyThreads(), fetchRepliedThreads()]);
  }

  // ---------------- FETCH MY THREADS ----------------
  Future<void> fetchMyThreads() async {
    try {
      isThreadsLoading.value = true;
      myThreads.clear();

      final threads = await threadsService
          .fetchMyThreads(); // fetch only current user's threads
      myThreads.value = threads;
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
      final commentsData = await commentsService.fetchReplies();
      repliedThreads.value = commentsData;
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
    final alreadyLiked = currentThread.likes.contains(threadsService.uid);

    // 🔁 Local optimistic update
    final updatedThread = currentThread.copyWith(
      likes: alreadyLiked
          ? currentThread.likes.where((id) => id != threadsService.uid).toList()
          : [...currentThread.likes, threadsService.uid!],
    );

    myThreads[index] = updatedThread;

    try {
      // 🔥 Server update
      if (alreadyLiked) {
        await threadsService.unlike(thread.id.toString());
      } else {
        await threadsService.like(thread.id.toString());

        // Send notification to thread owner
        if (thread.postedBy != threadsService.uid) {
          await _notificationsService.sendNotification(
            toUserId: thread.postedBy,
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
      Get.snackbar('Error', 'Failed to like thread');
    }
  }

  void onShareTapped(ThreadModel thread) {
    showSnackBar('Coming Soon', 'Share feature coming soon');
  }

  bool canEditThread(ThreadModel thread) {
    return thread.postedBy == uid;
  }

  bool canDeleteThread(ThreadModel thread) {
    return thread.postedBy == uid;
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
      showSnackBar(
        'Error',
        'Failed to delete thread',
      );
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
    await commentsService.deleteComment(reply.id.toString());

    repliedThreads.removeWhere((t) => t.id == reply.id);


    // Optional UI feedback
    showSnackBar(
      'Deleted',
      'Your reply has been deleted',
    ); } catch (e) {
      showSnackBar(
        'Error',
        'Failed to delete thread',
      );
    }
  }
}
