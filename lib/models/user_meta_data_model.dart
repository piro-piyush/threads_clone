/// UserMetaDataModel represents authentication-level
/// user metadata, usually provided by auth providers
/// (e.g. Supabase / OAuth / Email auth).
///
/// This model is commonly used for:
/// - User profile basics
/// - Verification status
/// - Auth-related UI decisions
///
/// It is intentionally kept separate from
/// app-specific UserModel for clean architecture.
class UserMetaDataModel {
  /// Unique subject identifier from auth provider
  /// (usually the same as auth user ID)
  final String sub;

  /// Display name of the user
  final String name;

  /// Email address of the user
  final String email;

  /// Profile image URL
  final String imageUrl;

  /// Timestamp when metadata was last updated
  final DateTime updatedAt;

  /// Short bio / description of the user
  final String description;

  /// Whether the user's email is verified
  final bool emailVerified;

  /// Whether the user's phone number is verified
  final bool phoneVerified;

  UserMetaDataModel({
    required this.sub,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.updatedAt,
    required this.description,
    required this.emailVerified,
    required this.phoneVerified,
  });

  // ---------------- FROM JSON ----------------

  /// Creates a UserMetaDataModel instance from JSON.
  ///
  /// Commonly used when parsing auth user metadata
  /// from providers like Supabase or OAuth services.
  factory UserMetaDataModel.fromJson(Map<String, dynamic> json) =>
      UserMetaDataModel(
        sub: json['sub'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        imageUrl: json['image_url'] as String,
        updatedAt: DateTime.parse(json['updated_at'] as String),
        description: json['description'] as String,
        emailVerified: json['email_verified'] as bool,
        phoneVerified: json['phone_verified'] as bool,
      );

  // ---------------- TO JSON ----------------

  /// Converts UserMetaDataModel into JSON format.
  ///
  /// Useful for:
  /// - Updating auth metadata
  /// - Local caching
  /// - Debugging
  Map<String, dynamic> toJson() => {
    'sub': sub,
    'name': name,
    'email': email,
    'image_url': imageUrl,
    'updated_at': updatedAt.toIso8601String(),
    'description': description,
    'email_verified': emailVerified,
    'phone_verified': phoneVerified,
  };
}
