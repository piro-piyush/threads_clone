import 'dart:io';
import 'package:get/get.dart';
import 'package:thread_clone/models/user_model.dart';
import 'package:thread_clone/utils/mixins/supabase_mixin.dart';

/// Service to manage user-related operations, including fetching,
/// updating profiles, uploading avatars, and searching users.
class UserService extends GetxService with SupabaseMixin {
  static const String table = 'users';
  static UserService get instance => Get.find<UserService>();

  // ---------------- GET CURRENT USER PROFILE ----------------
  /// Fetches the profile of the currently logged-in user.
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (!isLoggedIn) return null;
    return fetchSingle(table, column: 'id', value: uid);
  }

  // ---------------- GET ANY USER PROFILE ----------------
  /// Fetches the profile of any user by their ID.
  Future<UserModel?> getUserProfile(String userId) async {
    final data = await fetchSingle(table, column: 'id', value: userId);
    if (data == null) return null;

    return UserModel.fromJson(data);
  }

  // ---------------- UPDATE CURRENT USER PROFILE ----------------
  /// Updates the profile of the currently logged-in user.
  /// The `data` map should contain updated fields (e.g., name, bio).
  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (!isLoggedIn) throw Exception("User not logged in");

    // Add/update timestamp
    data['updated_at'] = DateTime.now().toIso8601String();

    // Update auth metadata if required
    await updateUserMetadata(data);

    // Update in Supabase 'users' table
    final dbData = {'metadata': data};
    await updateRow(table, whereColumn: 'id', whereValue: uid, data: dbData);
  }

  // ---------------- UPLOAD USER AVATAR ----------------
  /// Uploads a user avatar to Supabase Storage.
  /// Returns the public URL of the uploaded image.
  Future<String> uploadAvatar({
    required File file,
    required String bucket,
  }) async {
    if (!isLoggedIn) throw Exception("User not logged in");

    return uploadImage(file: file, bucket: bucket, folder: 'avatars/$uid');
  }

  // ---------------- FETCH ALL USERS ----------------
  /// Fetches all users, with an optional limit.
  Future<List<Map<String, dynamic>>> fetchAllUsers({int? limit}) async {
    return fetchList(
      table,
      orderBy: 'created_at',
      ascending: true,
      limit: limit,
    );
  }

  // ---------------- DELETE USER (SOFT) ----------------
  /// Soft deletes a user by setting `is_deleted` to true.
  Future<void> deleteUser(String userId) async {
    await updateRow(
      table,
      whereColumn: 'id',
      whereValue: userId,
      data: {'is_deleted': true},
    );
  }

  // ---------------- SEARCH USERS ----------------
  /// Searches users by name (case-insensitive).
  Future<List<UserModel>> searchUser(String name) async {
    if (!isLoggedIn) throw Exception("User not logged in");

    final List<Map<String, dynamic>> results = await supabase
        .from(table)
        .select('*')
        .ilike('metadata->>name', '%$name%');

    return results.map((e) => UserModel.fromJson(e)).toList();
  }
}
