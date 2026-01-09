import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thread_clone/controllers/thread_controller.dart';
import 'package:thread_clone/routes/route_names.dart';
import 'package:thread_clone/utils/helper.dart';
import 'package:thread_clone/widgets/circular_image_widget.dart';
import 'package:thread_clone/widgets/status_loader_widget.dart';
import 'package:thread_clone/widgets/thread_card_image_widget.dart';

class ThreadView extends StatelessWidget {
  const ThreadView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThreadController controller = Get.put(ThreadController());

    return Scaffold(
      appBar: AppBar(title: const Text('Thread')),
      body: Obx(() {
        // ---------------- LOADING ----------------
        if (controller.isLoading.value) {
          return const Center(
            child: StatusLoaderWidget(
              title: "Loading Thread...",
              subtitle: "Please wait",
              icon: Icons.chat_bubble_outline,
            ),
          );
        }

        final thread = controller.thread.value;

        // ---------------- ERROR / EMPTY ----------------
        if (thread == null) {
          return const Center(child: Text("Thread not found"));
        }

        return RefreshIndicator(
          onRefresh: controller.init,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------- THREAD CARD ----------------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircularProfileImageWidget(
                      url: thread.user.metadata.imageUrl,
                      radius: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                thread.user.metadata.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    thread.formattedCreatedAt,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_horiz),
                                    color: Colors.grey[900],
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        controller.editThread(thread);
                                      } else if (value == 'delete') {
                                        controller.deleteThread(
                                          context,
                                          thread,
                                        );
                                      } else {
                                        showSnackBar(
                                          'Coming Soon',
                                          'Report feature coming soon',
                                        );
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      if (controller.canEditThread(thread))
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                      if (controller.canDeleteThread(thread))
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      const PopupMenuItem(
                                        value: 'report',
                                        child: Text('Report'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Content
                          Text(
                            thread.content,
                            style: const TextStyle(fontSize: 14),
                          ),

                          // Image
                          if (thread.image != null) ...[
                            const SizedBox(height: 8),
                            ThreadCardImageWidget(imageUrl: thread.image),
                          ],

                          const SizedBox(height: 8),

                          // Actions
                          Row(
                            children: [
                              IconButton(
                                onPressed: controller.onLikeTapped,
                                icon: Icon(
                                  thread.isLiked(controller.uid)
                                      ? Icons.favorite
                                      : Icons.favorite_outline,
                                  color: thread.isLiked(controller.uid)
                                      ? Colors.red
                                      : Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Get.toNamed(
                                    RouteNames.addComment,
                                    arguments: thread.id,
                                  );
                                },
                                icon: const Icon(Icons.chat_bubble_outline),
                              ),
                              IconButton(
                                onPressed: controller.onShareTapped,
                                icon: const Icon(Icons.send),
                              ),
                            ],
                          ),

                          // Stats
                          Row(
                            children: [
                              Text("${thread.comments} replies"),
                              const SizedBox(width: 12),
                              Text("${thread.likesCount} likes"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(height: 32),

                // ---------------- REPLIES ----------------
                if (controller.isReplyLoading.value)
                  const Center(child: CircularProgressIndicator())
                else if (controller.replies.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "No replies yet",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.replies.length,
                    itemBuilder: (context, index) {
                      final reply = controller.replies[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,

                        leading: CircularProfileImageWidget(
                          url: reply.user.metadata.imageUrl,
                          radius: 20,
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                reply.user.metadata.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              reply.timeAgo,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(reply.content),

                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_horiz),
                          padding: EdgeInsets.zero,
                          color: Colors.grey[900],
                          onSelected: (value) {
                            if (value == 'edit') {
                              controller.deleteReply(context, reply);
                            } else if (value == 'delete') {
                              controller.deleteReply(context, reply);
                            } else {
                              showSnackBar(
                                'Coming Soon',
                                'Report feature coming soon',
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            if (controller.canEditReply(reply))
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                            if (controller.canDeleteReply(reply))
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            const PopupMenuItem(
                              value: 'report',
                              child: Text('Report'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
