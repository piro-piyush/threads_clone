import 'package:thread_clone/models/thread_model.dart';
import 'package:thread_clone/models/user_model.dart';

/// ReplyModel represents a single reply made on a thread.
///
/// It encapsulates:
/// - Reply content
/// - Author information
/// - Parent thread reference
/// - Creation & update timestamps
///
/// Designed as an immutable model to work seamlessly
/// with state management and backend serialization.
class ReplyModel {
  /// Unique identifier of the reply
  final int id;

  /// Text content of the reply
  final String content;

  /// Timestamp when the reply was created
  final DateTime createdAt;

  /// Timestamp when the reply was last edited (nullable)
  final DateTime? updatedAt;

  /// User who authored the reply
  final UserModel user;

  /// Thread to which this reply belongs
  final ThreadModel thread;

  const ReplyModel({
    required this.id,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    required this.user,
    required this.thread,
  });

  // ---------------- FROM JSON ----------------

  /// Creates a ReplyModel instance from JSON data.
  ///
  /// Typically used when fetching replies with
  /// joined user and thread data from backend.
  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    return ReplyModel(
      id: json['id'] as int,
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      user: UserModel.fromJson(Map<String, dynamic>.from(json['user'])),
      thread: ThreadModel.fromJson(Map<String, dynamic>.from(json['thread'])),
    );
  }

  // ---------------- TO JSON ----------------

  /// Converts ReplyModel into JSON.
  ///
  /// Useful for:
  /// - API requests
  /// - Local caching
  /// - Debugging
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user': user.toJson(),
      'thread': thread.toJson(),
    };
  }

  // ---------------- COPY WITH ----------------

  /// Returns a new ReplyModel instance with updated fields.
  ///
  /// Helps maintain immutability while updating state.
  ReplyModel copyWith({
    int? id,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? user,
    ThreadModel? thread,
  }) {
    return ReplyModel(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      thread: thread ?? this.thread,
    );
  }

  /// Returns human-readable relative time
  ///
  /// Examples:
  /// - "10s ago"
  /// - "5m ago"
  /// - "Yesterday"
  /// - "12/1/2026"
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);

    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  /// Indicates whether the reply was edited after creation
  bool get isEdited => updatedAt != null;
}
