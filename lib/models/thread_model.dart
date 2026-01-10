import 'package:thread_clone/models/user_model.dart';

class ThreadModel {
  final int id;
  final String content;
  final String? image;
  // final String postedBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likesCount;
  final int commentsCount;
  final bool allowReplies;
  final UserModel user;

  ThreadModel({
    required this.id,
    required this.content,
    this.image,
    // required this.postedBy,
    required this.createdAt,
    this.updatedAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.allowReplies = true,
    required this.user,
  });

  factory ThreadModel.fromJson(Map<String, dynamic> json) => ThreadModel(
    id: json['id'] as int,
    content: json['content'] as String,
    image: json['image'] as String?,
    // postedBy: json['posted_by'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'] as String)
        : null,
    likesCount: json['likes_count'] as int,
    commentsCount: json['comments_count'] as int,
    allowReplies: json['allow_replies'] ?? true,
    user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'image': image,
    // 'posted_by': postedBy,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'likes_count': likesCount,
    'comments_count': commentsCount,
    'allow_replies': allowReplies,
    'user': user.toJson(),
  };

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

  // bool isLiked(String uid) {
  //   return true;
  // }

  bool get isEdited => updatedAt != null;

  /// ------------------ COPY WITH ------------------
  ThreadModel copyWith({
    int? id,
    String? content,
    String? image,
    // String? postedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likesCount,
    int? commentsCount,
    bool? allowReplies,
    UserModel? user,
  }) {
    return ThreadModel(
      id: id ?? this.id,
      content: content ?? this.content,
      image: image ?? this.image,
      // postedBy: postedBy ?? this.postedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      allowReplies: allowReplies ?? this.allowReplies,
      user: user ?? this.user,
    );
  }
}
