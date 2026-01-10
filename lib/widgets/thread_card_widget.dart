import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thread_clone/models/thread_model.dart';
import 'package:thread_clone/routes/route_names.dart';
import 'package:thread_clone/utils/helper.dart';
import 'package:thread_clone/widgets/thread_card_bottom_widget.dart';
import 'package:thread_clone/widgets/thread_card_image_widget.dart';

import 'circular_image_widget.dart';

class ThreadCardWidget extends StatelessWidget {
  const ThreadCardWidget({
    super.key,
    required this.thread,
    required this.onLikeTapped,
    required this.onCommentTapped,
    required this.onShareTapped,
    required this.uid,
    required this.onTap,
    this.showDivider = true,
    this.child,
    required this.canEditThread,
    required this.canDeleteThread,
    required this.editThread,
    required this.deleteThread,
    required this.isLiked,
    required this.likesMap,
  });

  final ThreadModel thread;
  final Future<bool> Function(String threadId) isLiked;
  final Function(ThreadModel thread) onLikeTapped;
  final Function(ThreadModel thread) onCommentTapped;
  final Function(ThreadModel thread) onShareTapped;
  final bool Function(ThreadModel thread) canEditThread;
  final bool Function(ThreadModel thread) canDeleteThread;
  final Function(ThreadModel thread) editThread;
  final Function(ThreadModel thread) deleteThread;
  final VoidCallback onTap;
  final String uid;
  final RxMap<int, bool> likesMap;
  final bool showDivider;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header: Avatar + Name + Time + More Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircularProfileImageWidget(
                url: thread.user.metadata.imageUrl,
                radius: 20,
                onTap: (){
                  if (thread.user.id != uid) {
                    Get.toNamed(RouteNames.showProfile, arguments: thread.user.id);
                  }
                },
              ),

              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          thread.user.metadata.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              thread.formattedCreatedAt,
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
                                  editThread(thread);
                                } else if (value == 'delete') {
                                  deleteThread(thread);
                                } else {
                                  showSnackBar(
                                    'Coming Soon',
                                    'Report feature coming soon',
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                if (canEditThread(thread))
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                if (canDeleteThread(thread))
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

                    /// Content
                    Text(thread.content, style: const TextStyle(fontSize: 14)),

                    SizedBox(height: 4),

                    /// Thread image (if exists)
                    if (thread.image != null) ...[
                      ThreadCardImageWidget(imageUrl: thread.image),
                    ],

                    /// Optional: Likes / Comments / Replies placeholder
                    ThreadCardBottomWidget(
                      thread: thread,
                      onLikeTapped: onLikeTapped,
                      onCommentTapped: onCommentTapped,
                      onShareTapped: onShareTapped,
                      uid: uid,
                      isLiked: isLiked,
                      likesMap: likesMap,
                    ),
                  ],
                ),
              ),
            ],
          ),
          showDivider ? Divider(color: Color(0xFF242424)) : SizedBox.shrink(),
          ?child,
        ],
      ),
    );
  }
}
