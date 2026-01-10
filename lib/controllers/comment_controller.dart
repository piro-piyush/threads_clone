import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:thread_clone/models/thread_model.dart';
import 'package:thread_clone/services/comments_service.dart';
import 'package:thread_clone/services/notifications_service.dart';
import 'package:thread_clone/services/thread_like_service.dart';
import 'package:thread_clone/services/threads_service.dart';
import 'package:thread_clone/utils/enums.dart';
import 'package:thread_clone/utils/helper.dart';

class CommentController extends GetxController {
  final ThreadsService _threadsService = Get.find<ThreadsService>();
  final ThreadLikeService _threadLikeService = Get.find<ThreadLikeService>();

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

  RxMap<int, bool> get likesMap => _threadLikeService.likesMap;



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
      likesMap[thread.value!.id] = await _threadLikeService.isThreadLiked(
        threadId,
      );
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

    final wasLiked = await _threadLikeService.isThreadLiked(threadId);

    // 🚀 Optimistic update
    thread.value = currentThread.copyWith(
      likesCount: wasLiked
          ? currentThread.likesCount - 1
          : currentThread.likesCount + 1,
    );
    likesMap[thread.value!.id] = !wasLiked;
    try {
      if (wasLiked) {
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
      likesMap[thread.value!.id] = wasLiked;
      Get.rawSnackbar(
        message: 'Failed to update like',
        duration: const Duration(seconds: 2),
      );
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
        toUserId: thread.value!.user.id,
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
