import 'package:thread_clone/models/user_model.dart';

class ThreadModel {
  final int id;
  final String content;
  final String? image;
  final String postedBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> likes;
  final List<String> comments;
  final bool allowReplies;
  final UserModel user;

  ThreadModel({
    required this.id,
    required this.content,
    this.image,
    required this.postedBy,
    required this.createdAt,
    this.updatedAt,
    this.likes = const [],
    this.comments = const [],
    this.allowReplies = true,
    required this.user,
  });

  factory ThreadModel.fromJson(Map<String, dynamic> json) => ThreadModel(
    id: json['id'] as int,
    content: json['content'] as String,
    image: json['image'] as String?,
    postedBy: json['posted_by'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'] as String)
        : null,
    likes: List<String>.from(json['likes'] ?? []),
    comments: List<String>.from(json['comments'] ?? []),
    allowReplies: json['allow_replies'] ?? true,
    user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'image': image,
    'posted_by': postedBy,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'likes': likes,
    'comments': comments,
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

  int get likesCount => likes.length;

  int get commentsCount => comments.length;

  bool isLiked(String uid) => likes.contains(uid);

  bool get isEdited => updatedAt != null;
}
