import 'package:thread_clone/models/user_meta_data_model.dart';


class SearchedUserModel {
  final String id;
  final String email;
  final UserMetaDataModel? metadata;
  final DateTime createdAt;

  SearchedUserModel({
    required this.id,
    required this.email,
    required this.createdAt,
    this.metadata,
  });

  factory SearchedUserModel.fromJson(Map<String, dynamic> json) {
    return SearchedUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['created_at']),
      metadata: json['metadata'] != null
          ? UserMetaDataModel.fromJson(json['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      if (metadata != null) 'metadata': metadata!.toJson(),
    };
  }

  /// Instagram / Threads style time formatting
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
}

// class Metadata {
//   String? name;
//   String? image;
//   String? description;
//
//   Metadata({this.name, this.image, this.description});
//
//   Metadata.fromJson(Map<String, dynamic> json) {
//     name = json['name'];
//     image = json['image'];
//     description = json['description'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['name'] = name;
//     data['image'] = image;
//     data['description'] = description;
//     return data;
//   }
// }
