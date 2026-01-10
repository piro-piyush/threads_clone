class QueryGenerator {
  const QueryGenerator._(); // prevent instantiation

  // ---------------- USER ----------------
  static const String user = '''
    id,
    created_at,
    email,
    metadata
  ''';

  // ---------------- THREAD ----------------
  static const String threadBase = '''
    id,
    content,
    image,
    created_at,
    updated_at,
    likes_count,
    comments_count,
    allow_replies
  ''';

  static const String threadWithUser =
      '''
    $threadBase,
    user:posted_by ($user)
  ''';

  static const String threadWithLikesAndUser =
      '''
    $threadWithUser,
    likes:likes (
     $likeBase
    )
''';

  // ---------------- LIKES ----------------
  static const String likeBase = '''
    id,
    created_at,
    user_id,
    thread_id
  ''';

  static const String threadWithLikes =
      '''
    $threadWithUser,
    likes:likes (
      $likeBase
    )
  ''';

  // ---------------- COMMENTS / REPLIES ----------------
  static const String replyBase = '''
    id,
    content,
    created_at,
    updated_at
  ''';

  static const String replyWithUser =
      '''
    $replyBase,
    user:replied_by ($user)
  ''';

  static const String replyWithThread =
      '''
    $replyWithUser,
    thread:thread_id (
      $threadWithUser
    )
  ''';

  static const String replyWithThreadAndLikes =
      '''
    $replyBase,
    user:replied_by ($user),
    thread:thread_id (
      $threadWithLikes
    )
  ''';

  // ---------------- NOTIFICATIONS ----------------
  static const String notification =
      '''
    id,
    from_user_id,
    to_user_id,
    content,
    thread_id,
    type,
    has_read,
    is_deleted,
    created_at,
    updated_at,
    from_user:from_user_id ($user)
  ''';
}
