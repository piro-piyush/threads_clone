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

/// ProfileController handles all profile-related data:
///
/// Responsibilities:
/// - Fetch logged-in user's threads
/// - Fetch threads user has replied to
/// - Handle likes, delete actions
/// - Listen to realtime thread updates
/// - Permission checks for edit/delete
///
/// Used in:
/// - Profile screen tabs (My Threads / Replies)
class ProfileController extends GetxController {
  // ---------------- SERVICES ----------------

  /// Thread CRUD + realtime listener
  final ThreadsService threadsService = Get.find<ThreadsService>();

  /// Replies & comments handling
  final CommentsService commentsService = Get.find<CommentsService>();

  /// Like/unlike functionality
  final ThreadLikeService threadLikeService = Get.find<ThreadLikeService>();

  /// User related operations
  final UserService userService = Get.find<UserService>();

  /// Notifications dispatch
  final NotificationsService _notificationsService =
      Get.find<NotificationsService>();

  // ---------------- STATE ----------------

  /// Threads created by logged-in user
  final RxList<ThreadModel> myThreads = <ThreadModel>[].obs;

  /// Threads user has replied to
  final RxList<ReplyModel> repliedThreads = <ReplyModel>[].obs;

  /// Loading states
  final RxBool isThreadsLoading = false.obs;
  final RxBool isRepliesLoading = false.obs;

  /// Current user id
  String get uid => threadsService.currentUser!.id;

  /// Global likes cache
  RxMap<int, bool> get likesMap => threadLikeService.likesMap;

  /// Realtime thread subscription
  late final StreamSubscription<ThreadEvent> _threadSubscription;

  /// Like status checker
  Future<bool> Function(String threadId) get isThreadLiked =>
      threadLikeService.isThreadLiked;

  // ---------------- LIFECYCLE ----------------

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  @override
  void onClose() {
    _threadSubscription.cancel();
    threadsService.stopListening();
    super.onClose();
  }

  // ---------------- INIT PROFILE DATA ----------------

  /// Initializes profile feed & realtime listeners
  Future<void> initialize() async {
    try {
      await threadsService.startListening();
      _threadSubscription = threadsService.stream.listen(_handleThreadEvent);

      await Future.wait([fetchMyThreads(), fetchRepliedThreads()]);
    } catch (e) {
      Get.log('ProfileController Error: $e');
    }
  }

  // ---------------- REALTIME EVENTS ----------------

  /// Handles realtime thread insert/update/delete
  void _handleThreadEvent(ThreadEvent event) {
    switch (event.type) {
      case ThreadEventType.insert:
        // Add new thread if created by current user
        if (event.thread?.user.id == uid) {
          myThreads.insert(0, event.thread!);
          fillLikesMap([event.thread!]);
        }
        break;

      case ThreadEventType.update:
        // Update in My Threads
        final myIndex = myThreads.indexWhere((t) => t.id == event.thread?.id);
        if (myIndex != -1) {
          myThreads[myIndex] = event.thread!;
        }

        // Update thread inside replies list
        for (int i = 0; i < repliedThreads.length; i++) {
          if (repliedThreads[i].thread.id == event.thread?.id) {
            repliedThreads[i] = repliedThreads[i].copyWith(
              thread: event.thread!,
            );
          }
        }
        break;

      case ThreadEventType.delete:
        // Remove deleted thread everywhere
        myThreads.removeWhere((t) => t.id == event.threadId);
        repliedThreads.removeWhere((r) => r.thread.id == event.threadId);
        break;
    }
  }

  // ---------------- LIKES PREFILL ----------------

  /// Prefill like status for visible threads
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

  /// Fetch threads created by current user
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

  // ---------------- FETCH REPLIED THREADS ----------------

  /// Fetch threads user has replied to
  Future<void> fetchRepliedThreads() async {
    try {
      isRepliesLoading.value = true;

      final commentsData = await commentsService.fetchReplies(uid);

      repliedThreads.value = commentsData;

      fillLikesMap(commentsData.map((c) => c.thread).toList());
    } catch (e) {
      Get.log('fetchRepliedThreads Error: $e');
      repliedThreads.clear();
    } finally {
      isRepliesLoading.value = false;
    }
  }

  // ---------------- LIKE HANDLER ----------------

  /// Like / Unlike thread (optimistic update)
  void onLikeTapped(ThreadModel thread) async {
    if (!threadsService.isLoggedIn) return;

    final index = myThreads.indexWhere((t) => t.id == thread.id);
    if (index == -1) return;

    final currentThread = myThreads[index];
    final alreadyLiked = await threadLikeService.isThreadLiked(
      thread.id.toString(),
    );

    // 🔁 Optimistic UI update
    myThreads[index] = currentThread.copyWith(
      likesCount: alreadyLiked
          ? currentThread.likesCount - 1
          : currentThread.likesCount + 1,
    );
    likesMap[thread.id] = !alreadyLiked;

    try {
      if (alreadyLiked) {
        await threadLikeService.unlikeThread(thread.id.toString());
      } else {
        await threadLikeService.likeThread(thread.id.toString());

        // 🔔 Notify owner (if not self)
        if (thread.user.id != uid) {
          await _notificationsService.sendNotification(
            toUserId: thread.user.id,
            threadId: thread.id.toString(),
            content: NotificationType.like.description,
            type: NotificationType.like.value,
          );
        }
      }
    } catch (e) {
      // ❌ Rollback
      myThreads[index] = currentThread;
      likesMap[thread.id] = alreadyLiked;
      Get.snackbar('Error', 'Failed to like thread');
    }
  }

  // ---------------- SHARE ----------------

  void onShareTapped(ThreadModel thread) {
    showSnackBar('Coming Soon', 'Share feature coming soon');
  }

  // ---------------- PERMISSIONS ----------------

  bool canEditThread(ThreadModel thread) => thread.user.id == uid;

  bool canDeleteThread(ThreadModel thread) => thread.user.id == uid;

  // ---------------- DELETE THREAD ----------------

  /// Delete thread with confirmation
  Future<void> deleteThread(BuildContext context, ThreadModel thread) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        title: const Text('Delete thread?'),
        content: const Text(
          'This thread will be permanently deleted. '
          'All replies and likes will be lost.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      ),
    );

    if (shouldDelete != true) return;

    try {
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

  // ---------------- DELETE REPLY ----------------

  /// Delete reply from replied threads list
  Future<void> deleteReply(BuildContext context, ReplyModel reply) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        title: const Text('Delete reply?'),
        content: const Text(
          'This reply will be permanently deleted. '
          'You won’t be able to undo this action.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      ),
    );

    if (shouldDelete != true) return;

    try {
      await commentsService.deleteComment(
        reply.id.toString(),
        reply.thread.id.toString(),
      );

      repliedThreads.removeWhere((r) => r.id == reply.id);
      showSnackBar('Deleted', 'Your reply has been deleted');
    } catch (e) {
      showSnackBar('Error', 'Failed to delete reply');
    }
  }

  Future<void> editThread(ThreadModel thread) async {}

  Future<void> editReply(BuildContext context, ReplyModel reply) async {}
}
