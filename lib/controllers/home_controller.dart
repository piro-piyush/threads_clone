import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:thread_clone/models/thread_model.dart';
import 'package:thread_clone/services/thread_like_service.dart';
import 'package:thread_clone/services/threads_service.dart';
import 'package:thread_clone/services/notifications_service.dart';
import 'package:thread_clone/utils/enums.dart';
import 'package:thread_clone/utils/helper.dart';
import 'package:thread_clone/utils/thread_event.dart';

/// Controller responsible for:
/// - Fetching threads
/// - Listening to realtime thread updates
/// - Handling likes, delete & permissions
class HomeController extends GetxController {
  // ---------------- SERVICES ----------------
  final ThreadsService _threadsService = Get.find();
  final ThreadLikeService _likeService = Get.find();
  final NotificationsService _notificationService = Get.find();

  // ---------------- STATE ----------------
  /// All threads shown on home feed
  final RxList<ThreadModel> threads = <ThreadModel>[].obs;

  /// Loading indicator for initial fetch
  final RxBool isLoading = true.obs;

  RxMap<int, bool> get likesMap => _likeService.likesMap;

  /// Current logged in user id
  String get uid => _threadsService.currentUser!.id;

  late final StreamSubscription<ThreadEvent> _threadSubscription;

  Future<bool> Function(String threadId) get isThreadLiked =>
      _likeService.isThreadLiked;

  // ---------------- LIFECYCLE ----------------
  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  @override
  void onClose() {
    _threadSubscription.cancel();
    _threadsService.stopListening();
    super.onClose();
  }

  // ---------------- INIT ----------------
  Future<void> initialize() async {
    try {
      await _threadsService.startListening();
      _threadSubscription = _threadsService.stream.listen(_handleThreadEvent);

      await fetchThreads();
    } catch (e) {
      Get.log('HomeController Error: $e');
    }
  }

  // ---------------- REALTIME EVENTS ----------------
  /// Handles realtime insert/update/delete events
  void _handleThreadEvent(ThreadEvent event) {
    switch (event.type) {
      case ThreadEventType.insert:
        threads.insert(0, event.thread!);
        break;

      case ThreadEventType.update:
        final index = threads.indexWhere((t) => t.id == event.thread!.id);
        if (index != -1) {
          threads[index] = event.thread!;
        }
        break;

      case ThreadEventType.delete:
        threads.removeWhere((t) => t.id == event.threadId);
        break;
    }
  }

  // ---------------- FETCH ----------------
  /// Fetch threads & prefill likes state
  Future<void> fetchThreads() async {
    isLoading.value = true;

    final fetchedThreads = await _threadsService.fetchFeed();
    threads.value = fetchedThreads;

    await _fillLikesMap(fetchedThreads);

    isLoading.value = false;
  }

  /// Prefills likesMap for all visible threads
  Future<void> _fillLikesMap(List<ThreadModel> threads) async {
    await Future.wait(
      threads.map((thread) async {
        likesMap[thread.id] ??= await _likeService.isThreadLiked(
          thread.id.toString(),
        );
      }),
    );
  }

  // ---------------- LIKE ACTION ----------------
  /// Optimistic like/unlike handler
  Future<void> onLikeTapped(ThreadModel thread) async {
    final index = threads.indexWhere((t) => t.id == thread.id);
    if (index == -1) return;

    final currentThread = threads[index];
    final alreadyLiked = likesMap[thread.id] ?? false;

    // Optimistic UI update
    threads[index] = currentThread.copyWith(
      likesCount: alreadyLiked
          ? currentThread.likesCount - 1
          : currentThread.likesCount + 1,
    );
    likesMap[thread.id] = !alreadyLiked;

    try {
      if (alreadyLiked) {
        await _likeService.unlikeThread(thread.id.toString());
      } else {
        await _likeService.likeThread(thread.id.toString());

        // Fire & forget notification
        _notificationService
            .sendNotification(
              toUserId: thread.user.id,
              threadId: thread.id.toString(),
              content: NotificationType.like.description,
              type: NotificationType.like.value,
            )
            .catchError((_) {});
      }
    } catch (_) {
      // Rollback on failure
      threads[index] = currentThread;
      likesMap[thread.id] = alreadyLiked;
    }
  }

  // ---------------- SHARE ----------------
  void onShareTapped(ThreadModel thread) {
    showSnackBar('Coming Soon', 'Share feature coming soon');
  }

  // ---------------- PERMISSIONS ----------------
  bool canEditThread(ThreadModel thread) => thread.user.id == uid;

  bool canDeleteThread(ThreadModel thread) => thread.user.id == uid;

  // ---------------- EDIT ----------------
  Future<void> editThread(ThreadModel thread) async {

  }

  // ---------------- DELETE ----------------
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
}
