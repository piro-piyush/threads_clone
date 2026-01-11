import 'package:thread_clone/models/user_meta_data_model.dart';

/// UserModel represents an application-level user.
///
/// It acts as a bridge between:
/// - Authentication data (UserMetaDataModel)
/// - App-specific user identity
///
/// This model is intentionally lightweight and immutable,
/// making it safe to pass across the app.
class UserModel {
  /// Unique user identifier (from auth provider)
  final String id;

  /// Primary email address of the user
  final String email;

  /// Authentication & profile metadata
  ///
  /// Includes:
  /// - Display name
  /// - Profile image
  /// - Verification status
  final UserMetaDataModel metadata;

  /// Timestamp when the user account was created
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.metadata,
    required this.createdAt,
  });

  // ---------------- FROM JSON ----------------

  /// Creates a UserModel instance from JSON.
  ///
  /// Commonly used when parsing user records
  /// fetched from backend or auth services.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      metadata: UserMetaDataModel.fromJson(
        json['metadata'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // ---------------- TO JSON ----------------

  /// Converts UserModel into JSON format.
  ///
  /// Useful for:
  /// - API requests
  /// - Local persistence
  /// - Debugging
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'metadata': metadata.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ---------------- HELPERS ----------------

  /// Returns human-readable account age
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
}
