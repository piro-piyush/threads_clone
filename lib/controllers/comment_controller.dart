import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:thread_clone/models/thread_model.dart';
import 'package:thread_clone/services/comments_service.dart';
import 'package:thread_clone/services/notifications_service.dart';
import 'package:thread_clone/services/threads_service.dart';
import 'package:thread_clone/utils/enums.dart';
import 'package:thread_clone/utils/helper.dart';

class CommentController extends GetxController {
  final ThreadsService _threadsService = Get.find<ThreadsService>();
  final CommentsService _commentsService = Get.find<CommentsService>();
  final NotificationsService _notificationsService =
      Get.find<NotificationsService>();

  late final String threadId;

  final Rxn<ThreadModel> thread = Rxn<ThreadModel>();
  final RxBool isLoading = false.obs;
  final RxBool isReplying = false.obs;
  final RxString error = ''.obs;

  late final TextEditingController commentController;

  String get uid => _threadsService.uid ?? '';

  @override
  void onInit() {
    super.onInit();

    final arg = Get.arguments;

    if (arg == null) {
      error.value = 'Invalid thread id';
      return;
    }

    threadId = arg.toString().trim();

    if (threadId.isEmpty) {
      error.value = 'Invalid thread id';
      return;
    }

    commentController = TextEditingController();

    fetchThread();
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }

  // ---------------- THREAD ----------------

  Future<void> fetchThread() async {
    try {
      isLoading.value = true;
      error.value = '';

      thread.value = await _threadsService.fetchThread(threadId);
    } catch (e) {
      error.value = 'Failed to load thread';
      Get.log('FetchThread Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshThread() async {
    await fetchThread();
  }

  // ---------------- ACTIONS ----------------

  Future<void> onLikeTapped() async {
    final currentThread = thread.value;
    if (currentThread == null) return;

    final alreadyLiked = currentThread.isLiked(uid);

    // 🔁 Local optimistic update
    final updatedThread = currentThread.copyWith(
      likes: alreadyLiked
          ? currentThread.likes.where((id) => id != uid).toList()
          : [...currentThread.likes, uid],
    );

    thread.value = updatedThread;

    try {
      // 🔥 Server update
      if (alreadyLiked) {
        await _threadsService.unlike(threadId);
      } else {
        await _threadsService.like(threadId);
      }
    } catch (e) {
      // ❌ rollback if API fails
      thread.value = currentThread;
      Get.snackbar('Error', 'Failed to like thread');
    }
  }

  Future<void> onShareTapped() async {
    showSnackBar('Coming Soon', 'Share feature coming soon');
  }

  // ---------------- COMMENTS ----------------

  Future<void> uploadComment() async {
    if (isReplying.value) return;

    final content = commentController.text.trim();

    if (content.isEmpty) {
      Get.snackbar('Error', 'Comment cannot be empty');
      return;
    }

    if (thread.value == null) {
      Get.snackbar('Error', 'Thread not found');
      return;
    }

    try {
      isReplying.value = true;
      error.value = '';

      await _commentsService.addComment(threadId: threadId, content: content);
      await _notificationsService.sendNotification(
        toUserId: thread.value!.postedBy,
        threadId: threadId,
        content: NotificationType.reply.description,
        type: NotificationType.reply.value,
      );
      commentController.clear();
      Get.back();
      showSnackBar('Success', 'Comment posted successfully');
    } catch (e) {
      Get.log('UploadComment Error: $e');
      Get.snackbar('Error', 'Failed to post comment');
    } finally {
      isReplying.value = false;
    }
  }
}
