import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thread_clone/controllers/comment_controller.dart';
import 'package:thread_clone/widgets/circular_image_widget.dart';
import 'package:thread_clone/widgets/status_loader_widget.dart';
import 'package:thread_clone/widgets/thread_card_image_widget.dart';

class AddCommentView extends GetView<CommentController> {
  const AddCommentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reply"),
        centerTitle: false,
        leading: CloseButton(),
        actions: [
          Obx(() {
            if (controller.isLoading.value) {
              return SizedBox.shrink();
            }
            return TextButton(
              onPressed: controller.uploadComment,
              child: Text("Reply"),
            );
          }),
        ],
      ),
      body: Obx(() {
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

        if (thread == null) {
          return const Center(child: Text("Thread not found"));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header: Avatar + Name + Time + More Button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircularProfileImageWidget(
                        url: thread.user.metadata.imageUrl,
                        radius: 20,
                      ),

                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              spacing: 2,
                              children: [
                                Text(
                                  thread.user.metadata.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  thread.formattedCreatedAt,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            /// Content
                            SizedBox(height: 10),
                            Text(
                              thread.content,
                              style: const TextStyle(fontSize: 14),
                            ),

                            /// Thread image (if exists)
                            if (thread.image != null) ...[
                              const SizedBox(height: 4),
                              ThreadCardImageWidget(imageUrl: thread.image),

                              const SizedBox(height: 6),

                              /// Optional: Likes / Comments / Replies placeholder
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => controller.onLikeTapped(),
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
                                    onPressed:  controller.onShareTapped,
                                    icon: const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              TextFormField(
                                controller: controller.commentController,
                                maxLength: 1000,
                                maxLines: null,
                                minLines: 1,
                                decoration: InputDecoration(
                                  hintText: "Type a reply...",
                                  border: InputBorder.none,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
