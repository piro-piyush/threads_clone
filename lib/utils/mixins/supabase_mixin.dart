import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

mixin SupabaseMixin {
  // ---------------- CORE ----------------
  SupabaseClient get supabase => Supabase.instance.client;

  User? get currentUser => supabase.auth.currentUser;

  String? get uid => currentUser?.id;

  bool get isLoggedIn => currentUser != null;

  // ---------------- AUTH ----------------
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<void> updateUserMetadata(Map<String, dynamic> data) async {
    await supabase.auth.updateUser(UserAttributes(data: data));
  }

  // ---------------- DB HELPERS ----------------

  Future<List<Map<String, dynamic>>> fetchList(String table, {String? select, String? orderBy, bool ascending = false, int? limit, Map<String, dynamic>? filters}) async {
    dynamic query = supabase.from(table).select(select ?? '*');

    if (filters != null) {
      filters.forEach((key, value) {
        query = query.eq(key, value);
      });
    }

    if (orderBy != null) {
      query = query.order(orderBy, ascending: ascending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    final data = await query;
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>?> fetchSingle(String table, {required String column, required dynamic value, String? select}) async {
    final data = await supabase.from(table).select(select ?? '*').eq(column, value).maybeSingle();

    return data == null ? null : Map<String, dynamic>.from(data);
  }

  Future<void> insertRow(String table, Map<String, dynamic> data) async {
    await supabase.from(table).insert(data);
  }

  Future<void> updateRow(String table, {required Map<String, dynamic> data, required String whereColumn, required dynamic whereValue}) async {
    await supabase.from(table).update(data).eq(whereColumn, whereValue);
  }

  Future<void> deleteRow(String table, {required String whereColumn, required dynamic whereValue}) async {
    await supabase.from(table).delete().eq(whereColumn, whereValue);
  }

  // ---------------- STORAGE HELPERS ----------------
  Future<String> uploadImage({required File file, required String bucket, required String folder, String contentType = 'image/jpeg'}) async {
    final fileName = '${const Uuid().v4()}.jpg';
    final path = '$folder/$fileName';

    await supabase.storage.from(bucket).upload(path, file, fileOptions: FileOptions(contentType: contentType, upsert: true));

    return getPublicUrl(bucket, path);
  }

  String getPublicUrl(String bucket, String path) {
    return supabase.storage.from(bucket).getPublicUrl(path);
  }

  Future<void> deleteFile(String bucket, String path) async {
    await supabase.storage.from(bucket).remove([path]);
  }
}
