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

/// ThreadController manages a single thread screen.
///
/// Responsibilities:
/// - Fetching thread details
/// - Fetching & managing replies
/// - Handling likes, comments & delete actions
/// - Sending notifications
/// - Permission checks (edit/delete)
///
/// Uses:
/// - GetX for state management
/// - Supabase services for data operations
class ThreadController extends GetxController {
  // ---------------- SERVICES ----------------

  /// Thread CRUD & realtime operations
  final ThreadsService _threadsService = Get.find<ThreadsService>();

  /// Like/unlike handling
  final ThreadLikeService _threadLikeService = Get.find<ThreadLikeService>();

  /// Replies / comments handling
  final CommentsService _commentsService = Get.find<CommentsService>();

  /// Notification dispatching
  final NotificationsService _notificationsService =
      Get.find<NotificationsService>();

  // ---------------- STATE ----------------

  /// Thread id passed via navigation arguments
  late final String threadId;

  /// Current thread data
  final Rxn<ThreadModel> thread = Rxn<ThreadModel>();

  /// Replies of the thread
  final RxList<ReplyModel> replies = <ReplyModel>[].obs;

  /// Initial loading state
  final RxBool isLoading = false.obs;

  /// Replies-related loading
  final RxBool isReplyLoading = false.obs;

  /// Error message (if any)
  final RxString error = ''.obs;

  // ---------------- FORM ----------------

  /// Comment form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Comment input controller
  late final TextEditingController commentController;

  /// Global likes state
  RxMap<int, bool> get likesMap => _threadLikeService.likesMap;

  /// Current logged-in user id
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

  /// Extracts and validates navigation arguments
  void _resolveArguments() {
    final arg = Get.arguments;

    if (arg == null || arg.toString().trim().isEmpty) {
      error.value = 'Invalid thread id';
      return;
    }

    threadId = arg.toString().trim();
  }

  /// Initial data load
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

  /// Fetch single thread details
  Future<void> fetchThread() async {
    try {
      thread.value = await _threadsService.fetchThread(threadId);
    } catch (e) {
      error.value = 'Failed to load thread';
      Get.log('FetchThread Error: $e');
    }
  }

  // ---------------- FETCH REPLIES ----------------

  /// Fetch all replies of the thread
  Future<void> fetchReplies() async {
    try {
      isReplyLoading.value = true;

      replies.value = await _commentsService.fetchComments(threadId);

      /// Sync comments count with backend
      thread.value = thread.value?.copyWith(commentsCount: replies.length);
    } catch (e) {
      Get.log('FetchReplies Error: $e');
    } finally {
      isReplyLoading.value = false;
    }
  }

  /// Refresh thread only
  Future<void> refreshThread() async {
    await fetchThread();
  }

  // ---------------- LIKE THREAD ----------------

  /// Like / Unlike thread with optimistic UI update
  Future<void> onLikeTapped() async {
    final currentThread = thread.value;
    if (currentThread == null || uid.isEmpty) return;

    final alreadyLiked = await _threadLikeService.isThreadLiked(
      currentThread.id.toString(),
    );

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

        // 🔔 Notify thread owner
        await _notificationsService.sendNotification(
          toUserId: currentThread.user.id,
          threadId: threadId,
          content: NotificationType.like.description,
          type: NotificationType.like.value,
        );
      }
    } catch (e) {
      // ❌ Rollback on failure
      thread.value = currentThread;
      Get.snackbar('Error', 'Failed to update like');
    }
  }

  // ---------------- ADD COMMENT ----------------

  /// Add new reply/comment
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

  // ---------------- PERMISSIONS ----------------

  bool canEditReply(ReplyModel reply) => reply.user.metadata.sub == uid;

  bool canDeleteReply(ReplyModel reply) => reply.user.metadata.sub == uid;

  bool canEditThread(ThreadModel thread) => thread.user.id == uid;

  bool canDeleteThread(ThreadModel thread) => thread.user.id == uid;

  // ---------------- DELETE THREAD ----------------

  /// Delete thread with confirmation dialog
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
      Get.back();

      showSnackBar(
        'Thread Deleted',
        'Your thread has been deleted successfully',
      );
    } catch (e) {
      showSnackBar('Error', 'Failed to delete thread');
    }
  }

  // ---------------- DELETE REPLY ----------------

  /// Delete reply with confirmation
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
      await _commentsService.deleteComment(reply.id.toString(), threadId);

      replies.removeWhere((r) => r.id == reply.id);
      showSnackBar('Deleted', 'Your reply has been deleted');
    } catch (e) {
      showSnackBar('Error', 'Failed to delete reply');
    }
  }

  Future<void> editThread(ThreadModel thread) async {
    showSnackBar('Coming Soon', 'Edit feature coming soon');
  }
}
