import 'package:flutter/material.dart';
import 'package:thread_clone/models/thread_model.dart';

class ThreadCardBottomWidget extends StatelessWidget {
  const ThreadCardBottomWidget({
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onLikeTapped(thread),
              icon: Icon(
                thread.isLiked(uid) ? Icons.favorite : Icons.favorite_outline,
                color: thread.isLiked(uid) ? Colors.red : Colors.white,
              ),
            ),
            IconButton(
              onPressed: onCommentTapped(thread),
              icon: Icon(Icons.chat_bubble_outline, color: Colors.white),
            ),
            IconButton(
              onPressed: onShareTapped(thread),
              icon: Icon(Icons.send_outlined, color: Colors.white),
            ),
          ],
        ),
        Row(
          children: [
            Text("${thread.commentsCount} replies"),
            const SizedBox(width: 10),
            Text("${thread.likesCount} likes"),
          ],
        ),
      ],
    );
  }
}
