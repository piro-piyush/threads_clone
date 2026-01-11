import 'package:flutter/material.dart';

/// ---------------- NOTIFICATION TYPES ----------------
enum NotificationType {
  mention,
  reply,
  like,
  follow,
  message,
  trending,
  reminder,
  system,
}

/// ---------------- THREAD EVENTS ----------------
enum ThreadEventType {
  insert,
  update,
  delete,
}

/// ---------------- EXTENSIONS FOR NOTIFICATIONTYPE ----------------
extension NotificationTypeExtension on NotificationType {

  /// Friendly title to display in UI
  String get title {
    switch (this) {
      case NotificationType.mention:
        return "Mention";
      case NotificationType.reply:
        return "Reply";
      case NotificationType.like:
        return "Like";
      case NotificationType.follow:
        return "Follow";
      case NotificationType.message:
        return "Message";
      case NotificationType.trending:
        return "Trending Thread";
      case NotificationType.reminder:
        return "Reminder";
      case NotificationType.system:
        return "System";
    }
  }

  /// Icon to use in Flutter UI
  IconData get icon {
    switch (this) {
      case NotificationType.mention:
        return Icons.alternate_email;
      case NotificationType.reply:
        return Icons.reply;
      case NotificationType.like:
        return Icons.thumb_up;
      case NotificationType.follow:
        return Icons.person_add;
      case NotificationType.message:
        return Icons.message;
      case NotificationType.trending:
        return Icons.trending_up;
      case NotificationType.reminder:
        return Icons.notifications;
      case NotificationType.system:
        return Icons.settings;
    }
  }

  /// Description for the notification
  String get description {
    switch (this) {
      case NotificationType.mention:
        return "Someone mentioned you in a thread.";
      case NotificationType.reply:
        return "Someone replied to your thread.";
      case NotificationType.like:
        return "Someone liked your thread.";
      case NotificationType.follow:
        return "Someone followed your thread or profile.";
      case NotificationType.message:
        return "You received a direct message.";
      case NotificationType.trending:
        return "A thread you follow is trending.";
      case NotificationType.reminder:
        return "You have pending notifications.";
      case NotificationType.system:
        return "System message or update.";
    }
  }

  /// Convert enum to string
  String get value => name;

  /// Convert string back to enum
  static NotificationType fromString(String str) {
    return NotificationType.values.firstWhere(
          (e) => e.name == str,
      orElse: () => NotificationType.system, // default fallback
    );
  }
}
