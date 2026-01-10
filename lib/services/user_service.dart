import 'dart:io';
import 'package:get/get.dart';
import 'package:thread_clone/models/searched_user_model.dart';
import 'package:thread_clone/models/user_model.dart';
import 'package:thread_clone/utils/mixins/supabase_mixin.dart';

class UserService extends GetxService with SupabaseMixin {
  static const String table = 'users';

  static UserService get instance => Get.find<UserService>();

  // ---------------- GET CURRENT USER PROFILE ----------------
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (!isLoggedIn) return null;
    return fetchSingle(table, column: 'id', value: uid);
  }

  // ---------------- GET ANY USER PROFILE BY ID ----------------
  Future<UserModel?> getUserProfile(String userId) async {
    final data =  await fetchSingle(table, column: 'id', value: userId);
    if (data == null) return null;

    return UserModel.fromJson(data);
  }

  // ---------------- UPDATE CURRENT USER PROFILE ----------------
  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (!isLoggedIn) throw Exception("User not logged in");

    // Add updated_at timestamp
    data['updated_at'] = DateTime.now().toIso8601String();

    // Update in auth metadata (if needed)
    await updateUserMetadata(data);

    // Update in users table
    final dbData = {'metadata': data};
    await updateRow(table, whereColumn: 'id', whereValue: uid, data: dbData);
  }

  // ---------------- UPLOAD USER AVATAR ----------------
  Future<String> uploadAvatar({
    required File file,
    required String bucket,
  }) async {
    if (!isLoggedIn) throw Exception("User not logged in");

    // Upload to Supabase Storage
    return uploadImage(file: file, bucket: bucket, folder: 'avatars/$uid');
  }

  // ---------------- FETCH ALL USERS (OPTIONAL) ----------------
  Future<List<Map<String, dynamic>>> fetchAllUsers({int? limit}) async {
    return fetchList(
      table,
      orderBy: 'created_at',
      ascending: true,
      limit: limit,
    );
  }

  // ---------------- DELETE USER (SOFT DELETE) ----------------
  Future<void> deleteUser(String userId) async {
    await updateRow(
      table,
      whereColumn: 'id',
      whereValue: userId,
      data: {'is_deleted': true},
    );
  }

  Future<List<SearchedUserModel>> searchUser(String name) async {
    if (!isLoggedIn) throw Exception("User not logged in");

    final List<SearchedUserModel> users = [];
    final List<Map<String, dynamic>> results = await supabase
        .from("users")
        .select("*")
        .ilike("metadata->>name", "%$name%");

    for (final result in results) {
      users.add(SearchedUserModel.fromJson(result));
    }
    return users;
  }
}
