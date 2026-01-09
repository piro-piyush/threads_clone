import 'package:thread_clone/models/user_meta_data_model.dart';

class UserModel {
  final String email;
  final UserMetaDataModel metadata;

  UserModel({required this.email, required this.metadata});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    email: json['email'] as String,
    metadata: UserMetaDataModel.fromJson(json['metadata'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'email': email,
    'metadata': metadata.toJson(),
  };
}
