import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thread_clone/controllers/profile_controller.dart';
import 'package:thread_clone/models/reply_model.dart';
import 'package:thread_clone/models/thread_model.dart';
import 'package:thread_clone/routes/route_names.dart';
import 'package:thread_clone/utils/helper.dart';
import 'package:thread_clone/widgets/thread_card_widget.dart';

import 'circular_image_widget.dart';

class ThreadReplyWidget extends StatelessWidget {
  final ReplyModel reply;

  const ThreadReplyWidget({
    super.key,
    required this.reply,
    required this.isLiked,
    required this.onLikeTapped,
    required this.onCommentTapped,
    required this.onShareTapped,
    required this.canEditThread,
    required this.canDeleteThread,
    required this.editReply,
    required this.deleteReply,
    required this.onTap,
    required this.uid,
    required this.likesMap,
    required this.showDivider,
    this.child,
    required this.editThread,
    required this.deleteThread,
  });

  final Future<bool> Function(String threadId) isLiked;
  final Function(ThreadModel thread) onLikeTapped;
  final Function(ThreadModel thread) onCommentTapped;
  final Function(ThreadModel thread) onShareTapped;
  final bool Function(ThreadModel thread) canEditThread;
  final bool Function(ThreadModel thread) canDeleteThread;
  final Function(ThreadModel thread) editThread;
  final Function(ThreadModel thread) deleteThread;
  final Function(BuildContext context, ReplyModel reply) deleteReply;
  final Function(BuildContext context, ReplyModel reply) editReply;
  final VoidCallback onTap;
  final String uid;
  final RxMap<int, bool> likesMap;
  final bool showDivider;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------- HEADER --------
          Row(
            spacing: 10,
            children: [
              CircularProfileImageWidget(
                url: reply.user.metadata.imageUrl,
                radius: 20,
                onTap: () {
                  if (reply.user.id != uid) {
                    Get.toNamed(
                      RouteNames.showProfile,
                      arguments: reply.user.id,
                    );
                  }
                },
              ),

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      reply.user.metadata.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          reply.timeAgo,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_horiz),
                          color: Colors.grey[900],
                          onSelected: (value) {
                            if (value == 'edit') {
                              editReply(context, reply);
                            } else if (value == 'delete') {
                              deleteReply(context, reply);
                            } else {
                              showSnackBar(
                                'Coming Soon',
                                'Report feature coming soon',
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                'Delete ',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // -------- MY REPLY --------
          Text(reply.content, style: const TextStyle(fontSize: 15)),

          const SizedBox(height: 12),

          // -------- ORIGINAL THREAD PREVIEW --------
          ThreadCardWidget(
            thread: reply.thread,
            onTap: () {
              Get.toNamed(RouteNames.thread, arguments: reply.thread.id);
            },
            onLikeTapped: onLikeTapped,
            onCommentTapped: (thread) {
              Get.toNamed(RouteNames.addComment, arguments: thread.id);
            },
            onShareTapped: onShareTapped,
            uid: uid,
            canEditThread: canEditThread,
            canDeleteThread: canDeleteThread,
            editThread: editThread,
            deleteThread: (thread) => deleteThread(thread),
            isLiked: isLiked,
            likesMap: likesMap,
          ),
        ],
      ),
    );
  }
}
