import 'package:thread_clone/models/thread_model.dart';
import 'package:thread_clone/models/user_model.dart';

class ReplyModel {
  final int id;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final UserModel user;
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
  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    return ReplyModel(
      id: json['id'] as int,
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      user: UserModel.fromJson(
        Map<String, dynamic>.from(json['user']),
      ),
      thread: ThreadModel.fromJson(
        Map<String, dynamic>.from(json['thread']),
      ),
    );
  }

  // ---------------- TO JSON ----------------
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


  /// Human readable time
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);

    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  /// Edited indicator
  bool get isEdited => updatedAt != null;
}
