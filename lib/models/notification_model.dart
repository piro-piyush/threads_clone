import 'package:thread_clone/models/user_model.dart';
import 'package:thread_clone/utils/enums.dart';

/// NotificationModel represents a single notification entity
/// used across the application.
///
/// It supports:
/// - User-to-user notifications (like, reply, follow, mention)
/// - System-level notifications
/// - Thread-related notifications
///
/// This model is fully serializable and immutable,
/// making it safe for state management and caching.
class NotificationModel {
  /// Unique identifier of the notification
  final int id;

  /// User ID who triggered the notification
  final String fromUserId;

  /// User ID who receives the notification
  final String toUserId;

  /// Optional content/message of the notification
  /// (mainly used for system notifications)
  final String content;

  /// Related thread ID (nullable for non-thread notifications)
  final int? threadId;

  /// Notification type stored as string
  /// (mapped to NotificationType enum internally)
  final String type;

  /// Whether the notification has been read
  final bool hasRead;

  /// Soft delete flag (useful for analytics & recovery)
  final bool isDeleted;

  /// Timestamp when notification was created
  final DateTime createdAt;

  /// Timestamp when notification was last updated
  final DateTime? updatedAt;

  /// Sender user details (optional, usually joined from backend)
  final UserModel? fromUser;

  NotificationModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.content,
    this.threadId,
    required this.type,
    required this.hasRead,
    required this.isDeleted,
    required this.createdAt,
    this.updatedAt,
    this.fromUser,
  });

  /// Creates a NotificationModel instance from JSON
  ///
  /// Commonly used when fetching data from Supabase / REST APIs
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      fromUserId: json['from_user_id'] as String,
      toUserId: json['to_user_id'] as String,
      content: json['content'] as String,
      threadId: json['thread_id'] as int?,
      type: json['type'] as String,
      hasRead: json['has_read'] as bool,
      isDeleted: json['is_deleted'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      fromUser: json['from_user'] != null
          ? UserModel.fromJson(json['from_user'])
          : null,
    );
  }

  /// Converts NotificationModel into JSON
  ///
  /// Useful for:
  /// - API requests
  /// - Local caching
  /// - Debug logging
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'content': content,
      'thread_id': threadId,
      'type': type,
      'has_read': hasRead,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'from_user': fromUser?.toJson(),
    };
  }

  /// Creates a new instance by copying existing values
  /// and overriding selected fields.
  ///
  /// Ideal for immutable state updates.
  NotificationModel copyWith({
    int? id,
    String? fromUserId,
    String? toUserId,
    String? content,
    int? threadId,
    String? type,
    bool? hasRead,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? fromUser,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      content: content ?? this.content,
      threadId: threadId ?? this.threadId,
      type: type ?? this.type,
      hasRead: hasRead ?? this.hasRead,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fromUser: fromUser ?? this.fromUser,
    );
  }

  /// Returns human-readable time format
  ///
  /// Examples:
  /// - "5s ago"
  /// - "10m ago"
  /// - "Yesterday"
  /// - "12/1/2026"
  String get formattedCreatedAt {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inSeconds < 60) {
      return "${diff.inSeconds}s ago";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes}m ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours}h ago";
    } else if (diff.inDays == 1) {
      return "Yesterday";
    } else if (diff.inDays < 7) {
      return "${diff.inDays}d ago";
    } else {
      return "${createdAt.day}/${createdAt.month}/${createdAt.year}";
    }
  }

  /// Returns notification headline based on its type
  ///
  /// Type string is safely converted into enum
  /// to avoid runtime crashes.
  String get headlineText {
    final typeEnum = NotificationTypeExtension.fromString(type);

    switch (typeEnum) {
      case NotificationType.mention:
        return " mentioned you in a thread";
      case NotificationType.reply:
        return " replied to your thread";
      case NotificationType.like:
        return " liked your thread";
      case NotificationType.follow:
        return " started following you";
      case NotificationType.message:
        return " sent you a message";
      case NotificationType.trending:
        return "A thread you follow is trending";
      case NotificationType.reminder:
        return "You have pending notifications";
      case NotificationType.system:
        return content.isNotEmpty ? content : "System notification";
    }
  }
}
