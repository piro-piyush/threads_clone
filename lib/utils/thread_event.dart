import 'package:thread_clone/models/thread_model.dart';
import 'enums.dart';

/// Represents a real-time event for a thread
class ThreadEvent {
  /// Type of event (insert, update, delete)
  final ThreadEventType type;

  /// Thread object for insert/update events
  final ThreadModel? thread;

  /// Thread ID for delete events
  final int? threadId;

  ThreadEvent({
    required this.type,
    this.thread,
    this.threadId,
  });
}
