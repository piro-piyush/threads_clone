import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thread_clone/controllers/profile_controller.dart';
import 'package:thread_clone/models/thread_model.dart';
import 'package:thread_clone/routes/route_names.dart';
import 'package:thread_clone/widgets/thread_card_widget.dart';

class ThreadsWidget extends StatelessWidget {
  ThreadsWidget({super.key});

  final ProfileController profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: profileController.fetchMyThreads,
      child: Obx(() {
        // ---------------- LOADING ----------------
        if (profileController.isThreadsLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final threads = profileController.myThreads;

        // ---------------- EMPTY STATE ----------------
        if (threads.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.feed_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    "No Threads Yet",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "You haven't posted any threads yet.\nStart sharing your thoughts!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: profileController.fetchMyThreads,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Refresh"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // ---------------- THREADS LIST ----------------
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          physics: const BouncingScrollPhysics(),
          itemCount: threads.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final ThreadModel thread = threads[index];

            return ThreadCardWidget(
              thread: thread,
              onLikeTapped: profileController.onLikeTapped,
              onCommentTapped: (thread) {
                Get.toNamed(RouteNames.addComment, arguments: thread.id);
              },
              onTap: () {
                Get.toNamed(RouteNames.thread, arguments: thread.id);
              },
              onShareTapped: profileController.onShareTapped,
              uid: profileController.uid,

              canEditThread: profileController.canEditThread,
              canDeleteThread: profileController.canDeleteThread,
              editThread: profileController.editThread,
              deleteThread:(thread)=> profileController.deleteThread(context,thread),
            );
          },
        );
      }),
    );
  }
}
