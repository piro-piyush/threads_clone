import 'package:thread_clone/models/user_model.dart';

/// ThreadModel represents a single thread/post in the application.
///
/// It contains:
/// - Core thread content (text & image)
/// - Engagement metadata (likes, comments)
/// - Author information
/// - Timestamps for creation & updates
///
/// This model is immutable and optimized for
/// backend-driven state updates.
class ThreadModel {
  /// Unique identifier of the thread
  final int id;

  /// Text content of the thread
  final String content;

  /// Optional image URL attached to the thread
  final String? image;

  /// Timestamp when the thread was created
  final DateTime createdAt;

  /// Timestamp when the thread was last updated (nullable)
  final DateTime? updatedAt;

  /// Total number of likes on the thread
  final int likesCount;

  /// Total number of comments on the thread
  final int commentsCount;

  /// Flag to control whether replies are allowed
  final bool allowReplies;

  /// User who created the thread
  final UserModel user;

  ThreadModel({
    required this.id,
    required this.content,
    this.image,
    required this.createdAt,
    this.updatedAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.allowReplies = true,
    required this.user,
  });

  // ---------------- FROM JSON ----------------

  /// Creates a ThreadModel instance from JSON.
  ///
  /// Typically used when fetching threads along with
  /// joined user data from the backend.
  factory ThreadModel.fromJson(Map<String, dynamic> json) => ThreadModel(
    id: json['id'] as int,
    content: json['content'] as String,
    image: json['image'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'] as String)
        : null,
    likesCount: json['likes_count'] as int,
    commentsCount: json['comments_count'] as int,
    allowReplies: json['allow_replies'] ?? true,
    user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
  );

  // ---------------- TO JSON ----------------

  /// Converts ThreadModel into JSON format.
  ///
  /// Useful for:
  /// - API requests
  /// - Local caching
  /// - Debugging
  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'image': image,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'likes_count': likesCount,
    'comments_count': commentsCount,
    'allow_replies': allowReplies,
    'user': user.toJson(),
  };

  // ---------------- HELPERS ----------------

  /// Returns a human-readable creation time
  ///
  /// Examples:
  /// - "30s ago"
  /// - "2h ago"
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

  /// Indicates whether the thread was edited after creation
  bool get isEdited => updatedAt != null;

  // ---------------- COPY WITH ----------------

  /// Creates a new ThreadModel with updated fields
  /// while keeping the object immutable.
  ThreadModel copyWith({
    int? id,
    String? content,
    String? image,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      allowReplies: allowReplies ?? this.allowReplies,
      user: user ?? this.user,
    );
  }
}
