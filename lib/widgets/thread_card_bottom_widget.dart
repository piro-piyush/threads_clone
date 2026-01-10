import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:thread_clone/models/thread_model.dart';

class ThreadCardBottomWidget extends StatelessWidget {
  const ThreadCardBottomWidget({
    super.key,
    required this.thread,
    required this.onLikeTapped,
    required this.onCommentTapped,
    required this.onShareTapped,
    required this.uid,
    required this.isLiked,
    required this.likesMap,
  });

  final ThreadModel thread;

  final Function(ThreadModel thread) onCommentTapped;
  final Function(ThreadModel thread) onShareTapped;
  final String uid;
  final Function(ThreadModel thread) onLikeTapped;
  final Future<bool> Function(String threadId) isLiked;
  final RxMap<int, bool> likesMap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // In UI
            Obx(() {
              // ✅ Safe null check, default false
              final isLiked = likesMap[thread.id] ?? false;

              return IconButton(
                onPressed: () => onLikeTapped(thread),
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_outline,
                  color: isLiked ? Colors.red : Colors.white,
                ),
                tooltip: isLiked ? 'Unlike' : 'Like', // optional: UX improvement
              );
            }),

            IconButton(
              onPressed: () => onCommentTapped(thread),
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            ),
            IconButton(
              onPressed: () => onShareTapped(thread),
              icon: const Icon(Icons.send, color: Colors.white),
            ),
          ],
        ),
        Row(
          spacing: 10,
          children: [
            Text("${thread.commentsCount} replies"),
            Text("${thread.likesCount} likes"),
          ],
        ),
      ],
    );
  }
}
