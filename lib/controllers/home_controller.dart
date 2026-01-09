import 'package:get/get.dart';
import 'package:thread_clone/models/thread_model.dart';
import 'package:thread_clone/services/threads_service.dart';

class HomeController extends GetxController {
  final ThreadsService threadsService = Get.find<ThreadsService>();

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

  String get uid =>threadsService.currentUser!.id;

  Future<void> fetchThreads() async {
    isLoading.value = true;
    final fetchedThreads = await threadsService.fetchThreads();
    threads.value = fetchedThreads;
    isLoading.value = false;
  }

  void onLikeTapped(ThreadModel thread) {
    // Implement like functionality
  }

  void onCommentTapped(ThreadModel thread) {
    // Implement comment functionality
  }

  void onShareTapped(ThreadModel thread) {
    // Implement share functionality
  }
}
