import 'package:thread_clone/models/thread_model.dart';

import 'enums.dart';

class ThreadEvent {
  final ThreadEventType type;
  final ThreadModel? thread;
  final int? threadId;

  ThreadEvent({
    required this.type,
    this.thread,
    this.threadId,
  });
}