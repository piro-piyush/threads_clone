class UserMetaDataModel {
  final String sub;
  final String name;
  final String email;
  final String imageUrl;
  final DateTime updatedAt;
  final String description;
  final bool emailVerified;
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

  factory UserMetaDataModel.fromJson(Map<String, dynamic> json) => UserMetaDataModel(
    sub: json['sub'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    imageUrl: json['image_url'] as String,
    updatedAt: DateTime.parse(json['updated_at'] as String),
    description: json['description'] as String,
    emailVerified: json['email_verified'] as bool,
    phoneVerified: json['phone_verified'] as bool,
  );

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
