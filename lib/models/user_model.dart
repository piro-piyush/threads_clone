import 'package:thread_clone/models/user_meta_data_model.dart';

class UserModel {
  final String id;
  final String email;
  final UserMetaDataModel metadata;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.metadata,
    required this.createdAt,
  });

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'metadata': metadata.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
