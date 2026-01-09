import 'package:thread_clone/models/user_model.dart';
import 'package:thread_clone/utils/enums.dart';

class NotificationModel {
  final int id;
  final String fromUserId;
  final String toUserId;
  final String content;
  final int? threadId;
  final String type;
  final bool hasRead;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime? updatedAt;
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
      // Format as "Jan 9, 2026" if older than a week
      return "${createdAt.day}/${createdAt.month}/${createdAt.year}";
    }
  }

  String get headlineText {
    // Safely map type string to enum
    final typeEnum = NotificationTypeExtension.fromString(type);

    // Get the user's name if available
    final fromName = fromUser?.metadata.name ?? "Someone";

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
