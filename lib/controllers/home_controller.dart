import 'package:get/get.dart';
import 'package:thread_clone/models/thread_model.dart';
import 'package:thread_clone/services/notifications_service.dart';
import 'package:thread_clone/services/threads_service.dart';
import 'package:thread_clone/utils/enums.dart';
import 'package:thread_clone/utils/helper.dart';

class HomeController extends GetxController {
  final ThreadsService threadsService = Get.find<ThreadsService>();
  final NotificationsService _notificationsService =
      Get.find<NotificationsService>();
  final isLoading = false.obs;

  RxList<ThreadModel> threads = <ThreadModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    init();
  }

  Future<void> init() async {
    threads.clear();
    await fetchThreads();
  }

  String get uid => threadsService.currentUser!.id;

  Future<void> fetchThreads() async {
    isLoading.value = true;
    final fetchedThreads = await threadsService.fetchThreads();
    threads.value = fetchedThreads;
    isLoading.value = false;
  }

  void onLikeTapped(ThreadModel thread) async {
    final index = threads.indexWhere((t) => t.id == thread.id);
    if (index == -1) return;

    final currentThread = threads[index];
    final alreadyLiked = currentThread.isLiked(uid);

    // 🔁 Local optimistic update
    final updatedThread = currentThread.copyWith(
      likes: alreadyLiked
          ? currentThread.likes.where((id) => id != uid).toList()
          : [...currentThread.likes, uid],
    );

    threads[index] = updatedThread;

    try {
      // 🔥 Server update
      if (alreadyLiked) {
        await threadsService.unlike(thread.id.toString());
      } else {
        await threadsService.like(thread.id.toString());
        await _notificationsService.sendNotification(
          toUserId: thread.postedBy,
          threadId: thread.id.toString(),
          content: NotificationType.like.description,
          type: NotificationType.like.value,
        );
      }
    } catch (e) {
      // ❌ Rollback on error
      threads[index] = currentThread;
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

  Future<void> editThread(ThreadModel thread) async {
  }

  Future<void> deleteThread(ThreadModel thread) async {
  }
}
