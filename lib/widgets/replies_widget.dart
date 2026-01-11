import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thread_clone/controllers/profile_controller.dart';
import 'package:thread_clone/routes/route_names.dart';

import 'package:thread_clone/widgets/thread_reply_widget.dart';

class RepliesWidget extends StatelessWidget {
  RepliesWidget({super.key});

  final ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ---------------- LOADING ----------------
      if (controller.isRepliesLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // ---------------- EMPTY STATE ----------------
      if (controller.repliedThreads.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.reply_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "No Replies Yet",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  "You haven’t replied to any threads yet.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        );
      }

      // ---------------- LIST ----------------
      return ListView.separated(
        padding: const EdgeInsets.all(12),
        physics: const BouncingScrollPhysics(),
        itemCount: controller.repliedThreads.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final reply = controller.repliedThreads[index];
          return ThreadReplyWidget(
            reply: reply,

            onLikeTapped: controller.onLikeTapped,
            uid: controller.uid,
            likesMap: controller.likesMap,
            isLiked: controller.threadLikeService.isThreadLiked,
            onCommentTapped: (thread) {
              Get.toNamed(RouteNames.addComment, arguments: thread.id);
            },
            onShareTapped: controller.onShareTapped,

            canEditThread: controller.canEditThread,
            canDeleteThread: controller.canDeleteThread,

            editThread: controller.editThread,
            deleteThread: (thread) => controller.deleteThread(context, thread),
            editReply: controller.editReply,
            deleteReply: controller.deleteReply,
            onTap: () {
              Get.toNamed(
                RouteNames.thread,
                arguments: controller.repliedThreads[index].thread.id,
              );
            },
            showDivider: true,
          );
        },
      );
    });
  }


}
