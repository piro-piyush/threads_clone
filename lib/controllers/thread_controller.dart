import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thread_clone/models/reply_model.dart';
import 'package:thread_clone/models/thread_model.dart';
import 'package:thread_clone/services/comments_service.dart';
import 'package:thread_clone/services/notifications_service.dart';
import 'package:thread_clone/services/thread_like_service.dart';
import 'package:thread_clone/services/threads_service.dart';
import 'package:thread_clone/utils/enums.dart';
import 'package:thread_clone/utils/helper.dart';

class ThreadController extends GetxController {
  // ---------------- SERVICES ----------------
  final ThreadsService _threadsService = Get.find<ThreadsService>();
  final ThreadLikeService _threadLikeService = Get.find<ThreadLikeService>();
  final CommentsService _commentsService = Get.find();
  final NotificationsService _notificationsService = Get.find();

  // ---------------- STATE ----------------
  late final String threadId;

  final Rxn<ThreadModel> thread = Rxn<ThreadModel>();
  final RxList<ReplyModel> replies = <ReplyModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isReplyLoading = false.obs;
  final RxString error = ''.obs;

  // ---------------- FORM ----------------
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late final TextEditingController commentController;
  RxMap<int, bool> get likesMap => _threadLikeService.likesMap;
  String get uid => _threadsService.uid ?? '';

  // ---------------- LIFECYCLE ----------------
  @override
  void onInit() {
    super.onInit();

    _resolveArguments();

    commentController = TextEditingController();

    init();
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }

  // ---------------- INIT ----------------
  void _resolveArguments() {
    final arg = Get.arguments;

    if (arg == null || arg.toString().trim().isEmpty) {
      error.value = 'Invalid thread id';
      return;
    }

    threadId = arg.toString().trim();
  }

  Future<void> init() async {
    if (error.isNotEmpty) return;

    isLoading.value = true;
    error.value = '';

    try {
      await Future.wait([fetchThread(), fetchReplies()]);
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- FETCH THREAD ----------------
  Future<void> fetchThread() async {
    try {
      thread.value = await _threadsService.fetchThread(threadId);
    } catch (e) {
      error.value = 'Failed to load thread';
      Get.log('FetchThread Error: $e');
    }
  }

  // ---------------- FETCH REPLIES ----------------
  Future<void> fetchReplies() async {
    try {
      isReplyLoading.value = true;
      replies.value = await _commentsService.fetchComments(threadId);

      // sync comment count with backend data
      thread.value = thread.value?.copyWith(commentsCount: replies.length);
    } catch (e) {
      Get.log('FetchReplies Error: $e');
    } finally {
      isReplyLoading.value = false;
    }
  }

  Future<void> refreshThread() async {
    await fetchThread();
  }

  // ---------------- LIKE THREAD ----------------
  Future<void> onLikeTapped() async {
    final currentThread = thread.value;
    if (currentThread == null || uid.isEmpty) return;

    final alreadyLiked = await _threadLikeService.isThreadLiked(currentThread.id.toString());

    // 🔁 Optimistic update
    thread.value = currentThread.copyWith(
      likesCount: alreadyLiked
          ? currentThread.likesCount - 1
          : currentThread.likesCount + 1,
    );
    try {
      if (alreadyLiked) {
        await _threadLikeService.unlikeThread(threadId);
      } else {
        await _threadLikeService.likeThread(threadId);

        await _notificationsService.sendNotification(
          toUserId: currentThread.user.id,
          threadId: threadId,
          content: NotificationType.like.description,
          type: NotificationType.like.value,
        );
      }
    } catch (e) {
      // ❌ rollback
      thread.value = currentThread;
      Get.snackbar('Error', 'Failed to update like');
    }
  }

  // ---------------- ADD COMMENT ----------------
  Future<void> addComment() async {
    if (!formKey.currentState!.validate()) return;

    final content = commentController.text.trim();
    if (content.isEmpty) return;

    try {
      isReplyLoading.value = true;

      await _commentsService.addComment(threadId: threadId, content: content);

      commentController.clear();
      await fetchReplies();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add comment');
    } finally {
      isReplyLoading.value = false;
    }
  }

  // ---------------- SHARE ----------------
  void onShareTapped() {
    showSnackBar('Coming Soon', 'Share feature coming soon');
  }

  bool canEditReply(ReplyModel reply) {
    return reply.user.metadata.sub == uid;
  }

  bool canDeleteReply(ReplyModel reply) {
    return reply.user.metadata.sub == uid;
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
      await _threadsService.deleteThread(thread.id.toString());
      Get.back();
      showSnackBar(
        'Thread Deleted',
        'Your thread has been deleted successfully',
      );
    } catch (e) {
      showSnackBar('Error', 'Failed to delete thread');
    }
  }

  bool canEditThread(ThreadModel thread) {
    return thread.user.id == uid;
  }

  bool canDeleteThread(ThreadModel thread) {
    return thread.user.id == uid;
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
      await _commentsService.deleteComment(reply.id.toString(), threadId);
      replies.removeWhere((t) => t.id == reply.id);

      // Optional UI feedback
      showSnackBar('Deleted', 'Your reply has been deleted');
    } catch (e) {
      showSnackBar('Error', 'Failed to delete thread');
    }
  }
}
