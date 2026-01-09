import 'dart:io';
import 'package:get/get.dart';
import 'package:thread_clone/utils/mixins/supabase_mixin.dart';

class UserService extends GetxService with SupabaseMixin {
  static const String table = 'users';

  // ---------------- GET CURRENT USER PROFILE ----------------
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (!isLoggedIn) return null;
    return fetchSingle(table, column: 'id', value: uid);
  }

  // ---------------- GET ANY USER PROFILE BY ID ----------------
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    return fetchSingle(table, column: 'id', value: userId);
  }

  // ---------------- UPDATE CURRENT USER PROFILE ----------------
  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (!isLoggedIn) throw Exception("User not logged in");

    // Add updated_at timestamp
    data['updated_at'] = DateTime.now().toIso8601String();

    // Update in auth metadata (if needed)
    await updateUserMetadata(data);

    // Update in users table
    final dbData = {
      'metadata':data,
    };
    await updateRow(table, whereColumn: 'id', whereValue: uid, data: dbData);
  }

  // ---------------- UPLOAD USER AVATAR ----------------
  Future<String> uploadAvatar({required File file, required String bucket}) async {
    if (!isLoggedIn) throw Exception("User not logged in");

    // Upload to Supabase Storage
    return uploadImage(file: file, bucket: bucket, folder: 'avatars/$uid');
  }

  // ---------------- FETCH ALL USERS (OPTIONAL) ----------------
  Future<List<Map<String, dynamic>>> fetchAllUsers({int? limit}) async {
    return fetchList(table, orderBy: 'created_at', ascending: true, limit: limit);
  }

  // ---------------- DELETE USER (SOFT DELETE) ----------------
  Future<void> deleteUser(String userId) async {
    await updateRow(table, whereColumn: 'id', whereValue: userId, data: {'is_deleted': true});
  }
}
