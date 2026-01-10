import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:thread_clone/models/reply_model.dart';
import 'package:thread_clone/models/thread_model.dart';
import 'package:thread_clone/models/user_model.dart';

import 'package:thread_clone/services/comments_service.dart';
import 'package:thread_clone/services/notifications_service.dart';
import 'package:thread_clone/services/thread_like_service.dart';
import 'package:thread_clone/services/threads_service.dart';
import 'package:thread_clone/services/user_service.dart';

import 'package:thread_clone/utils/enums.dart';
import 'package:thread_clone/utils/helper.dart';
import 'package:thread_clone/utils/thread_event.dart';

/// Controller for public profile of any user
/// Handles:
/// - User profile
/// - User threads
/// - Threads user replied to
/// - Realtime thread updates
/// - Likes
class PublicProfileController extends GetxController {
  // ---------------- SERVICES ----------------
  final ThreadsService _threadsService = Get.find();
  final CommentsService _commentsService = Get.find();
  final ThreadLikeService _likeService = Get.find();
  final UserService _userService = Get.find();
  final NotificationsService _notificationsService = Get.find();

  // ---------------- STATE ----------------
  final RxList<ThreadModel> threads = <ThreadModel>[].obs;
  final RxList<ReplyModel> repliedThreads = <ReplyModel>[].obs;

  final RxBool isThreadsLoading = false.obs;
  final RxBool isRepliesLoading = false.obs;
  final RxBool isUserLoading = false.obs;

  final Rxn<UserModel> user = Rxn<UserModel>();

  RxMap<int, bool> get likesMap => _likeService.likesMap;

  ThreadsService get threadsService => _threadsService;
  ThreadLikeService get threadLikeService => _likeService;


  late final String profileUserId;
  late final StreamSubscription<ThreadEvent> _threadSubscription;

  String get uid => _threadsService.currentUser!.id;

  // ---------------- LIFECYCLE ----------------
  @override
  void onInit() {
    super.onInit();
    final id  = Get.arguments;
    if(id!=null){
      profileUserId = id;
    }
    _initialize();
  }

  @override
  void onClose() {
    _threadSubscription.cancel();
    _threadsService.stopListening();
    super.onClose();
  }

  // ---------------- INIT ----------------
  Future<void> _initialize() async {
    try {
      await _threadsService.startListening();
      _threadSubscription =
          _threadsService.stream.listen(_handleThreadEvent);

      await Future.wait([
        fetchUser(),
        fetchThreads(),
        fetchRepliedThreads(),
      ]);
    } catch (e) {
      Get.log('PublicProfileController Error: $e');
    }
  }

  // ---------------- FETCH USER ----------------
  Future<void> fetchUser() async {
    try {
      isUserLoading.value = true;
      user.value = await _userService.getUserProfile(profileUserId);
    } catch (e) {
      Get.log('fetchUser Error: $e');
    } finally {
      isUserLoading.value = false;
    }
  }

  // ---------------- REALTIME EVENTS ----------------
  void _handleThreadEvent(ThreadEvent event) {
    switch (event.type) {
      case ThreadEventType.insert:
      // Only threads of this profile user
        if (event.thread?.user.id == profileUserId) {
          threads.insert(0, event.thread!);
          _fillLikesMap([event.thread!]);
        }
        break;

      case ThreadEventType.update:
      // Update in main threads
        final index =
        threads.indexWhere((t) => t.id == event.thread?.id);
        if (index != -1) {
          threads[index] = event.thread!;
        }

        // Update embedded thread inside replies
        for (int i = 0; i < repliedThreads.length; i++) {
          if (repliedThreads[i].thread.id == event.thread?.id) {
            repliedThreads[i] =
                repliedThreads[i].copyWith(thread: event.thread!);
          }
        }
        break;

      case ThreadEventType.delete:
        threads.removeWhere((t) => t.id == event.threadId);
        repliedThreads.removeWhere(
              (r) => r.thread.id == event.threadId,
        );
        break;
    }
  }

  // ---------------- LIKES ----------------
  Future<void> _fillLikesMap(List<ThreadModel> threads) async {
    await Future.wait(
      threads.map((thread) async {
        likesMap[thread.id] ??=
        await _likeService.isThreadLiked(thread.id.toString());
      }),
    );
  }

  // ---------------- FETCH THREADS ----------------
  Future<void> fetchThreads() async {
    try {
      isThreadsLoading.value = true;
      threads.clear();

      final fetched =
      await _threadsService.fetchThreads(profileUserId);
      threads.value = fetched;

      await _fillLikesMap(fetched);
    } catch (e) {
      Get.log('fetchThreads Error: $e');
      threads.clear();
    } finally {
      isThreadsLoading.value = false;
    }
  }

  // ---------------- FETCH REPLIES ----------------
  Future<void> fetchRepliedThreads() async {
    try {
      isRepliesLoading.value = true;

      final replies =
      await _commentsService.fetchReplies(profileUserId);
      repliedThreads.value = replies;

      await _fillLikesMap(
        replies.map((r) => r.thread).toList(),
      );
    } catch (e) {
      Get.log('fetchRepliedThreads Error: $e');
      repliedThreads.clear();
    } finally {
      isRepliesLoading.value = false;
    }
  }

  // ---------------- LIKE ACTION ----------------
  Future<void> onLikeTapped(ThreadModel thread) async {
    if (!_threadsService.isLoggedIn) return;

    final index = threads.indexWhere((t) => t.id == thread.id);
    if (index == -1) return;

    final current = threads[index];
    final alreadyLiked = likesMap[thread.id] ?? false;

    // Optimistic update
    threads[index] = current.copyWith(
      likesCount: alreadyLiked
          ? current.likesCount - 1
          : current.likesCount + 1,
    );
    likesMap[thread.id] = !alreadyLiked;

    try {
      if (alreadyLiked) {
        await _likeService.unlikeThread(thread.id.toString());
      } else {
        await _likeService.likeThread(thread.id.toString());

        if (thread.user.id != uid) {
          _notificationsService
              .sendNotification(
            toUserId: thread.user.id,
            threadId: thread.id.toString(),
            content: NotificationType.like.description,
            type: NotificationType.like.value,
          )
              .catchError((Object _) {});
        }
      }
    } catch (_) {
      // rollback
      threads[index] = current;
      likesMap[thread.id] = alreadyLiked;
      showSnackBar('Error', 'Failed to like thread');
    }
  }

  // ---------------- PERMISSIONS ----------------
  bool canEditThread(ThreadModel thread) => thread.user.id == uid;

  bool canDeleteThread(ThreadModel thread) => thread.user.id == uid;

  // ---------------- SHARE ----------------
  void onShareTapped(ThreadModel thread) {
    showSnackBar('Coming Soon', 'Share feature coming soon');
  }

  // ---------------- DELETE THREAD ----------------
  Future<void> deleteThread(
      BuildContext context,
      ThreadModel thread,
      ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
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
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await _threadsService.deleteThread(thread.id.toString());
      threads.removeWhere((t) => t.id == thread.id);
      showSnackBar(
        'Thread Deleted',
        'Your thread has been deleted successfully',
      );
    } catch (_) {
      showSnackBar('Error', 'Failed to delete thread');
    }
  }

  // ---------------- DELETE REPLY ----------------
  Future<void> deleteReply(
      BuildContext context,
      ReplyModel reply,
      ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
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
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await _commentsService.deleteComment(
        reply.id.toString(),
        reply.thread.id.toString(),
      );

      repliedThreads.removeWhere((r) => r.id == reply.id);
      showSnackBar('Deleted', 'Your reply has been deleted');
    } catch (_) {
      showSnackBar('Error', 'Failed to delete reply');
    }
  }


  Future<void> editThread(ThreadModel thread) async {}
}
