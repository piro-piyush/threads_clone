import 'package:flutter/material.dart';
import 'package:thread_clone/models/thread_model.dart';
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
  });

  final ThreadModel thread;

  final Function(ThreadModel thread) onLikeTapped;
  final Function(ThreadModel thread) onCommentTapped;
  final Function(ThreadModel thread) onShareTapped;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return Column(
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
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 8,
                              right: 8,
                              top: 0,
                              bottom: 4,
                            ),
                            child: InkWell(
                              onTap: () {},
                              child: const Icon(Icons.more_horiz),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  /// Content
                  Text(thread.content, style: const TextStyle(fontSize: 14)),

                  /// Thread image (if exists)
                  if (thread.image != null) ...[
                    const SizedBox(height: 10),
                    ThreadCardImageWidget(thread: thread),

                    const SizedBox(height: 12),

                    /// Optional: Likes / Comments / Replies placeholder
                    ThreadCardBottomWidget(
                      thread: thread,
                      onLikeTapped: onLikeTapped,
                      onCommentTapped: onCommentTapped,
                      onShareTapped: onShareTapped,
                      uid: uid,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        Divider(color: Color(0xFF242424)),
      ],
    );
  }
}
