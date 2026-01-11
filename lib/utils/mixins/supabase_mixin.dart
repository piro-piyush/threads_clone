import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// A mixin providing core Supabase helpers for auth, database, and storage operations.
/// Can be used across services like ThreadsService, UserService, CommentsService, etc.
mixin SupabaseMixin {
  // ---------------- CORE ----------------
  /// Returns the Supabase client instance
  SupabaseClient get supabase => Supabase.instance.client;

  /// Returns the currently authenticated user, or null if not logged in
  User? get currentUser => supabase.auth.currentUser;

  /// Returns the current user's ID, or null if not logged in
  String? get uid => currentUser?.id;

  /// Returns true if a user is logged in
  bool get isLoggedIn => currentUser != null;

  // ---------------- AUTH ----------------
  /// Sign out the current user
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  /// Update metadata of the currently logged-in user
  Future<void> updateUserMetadata(Map<String, dynamic> data) async {
    await supabase.auth.updateUser(UserAttributes(data: data));
  }

  // ---------------- DATABASE HELPERS ----------------

  /// Fetch a list of rows from a table with optional filtering, ordering, and limit
  Future<List<Map<String, dynamic>>> fetchList(
      String table, {
        String? select,
        String? orderBy,
        bool ascending = false,
        int? limit,
        Map<String, dynamic>? filters,
      }) async {
    dynamic query = supabase.from(table).select(select ?? '*');

    // Apply filters
    if (filters != null) {
      filters.forEach((key, value) {
        query = query.eq(key, value);
      });
    }

    // Apply ordering
    if (orderBy != null) {
      query = query.order(orderBy, ascending: ascending);
    }

    // Apply limit
    if (limit != null) {
      query = query.limit(limit);
    }

    final data = await query;
    return List<Map<String, dynamic>>.from(data);
  }

  /// Fetch a single row by column value
  Future<Map<String, dynamic>?> fetchSingle(
      String table, {
        required String column,
        required dynamic value,
        String? select,
      }) async {
    final data = await supabase.from(table).select(select ?? '*').eq(column, value).maybeSingle();
    return data == null ? null : Map<String, dynamic>.from(data);
  }

  /// Insert a row into a table
  Future<void> insertRow(String table, Map<String, dynamic> data) async {
    await supabase.from(table).insert(data);
  }

  /// Update a row in a table by a specific column
  Future<void> updateRow(
      String table, {
        required Map<String, dynamic> data,
        required String whereColumn,
        required dynamic whereValue,
      }) async {
    await supabase.from(table).update(data).eq(whereColumn, whereValue);
  }

  /// Delete a row in a table by a specific column
  Future<void> deleteRow(
      String table, {
        required String whereColumn,
        required dynamic whereValue,
      }) async {
    await supabase.from(table).delete().eq(whereColumn, whereValue);
  }

  // ---------------- STORAGE HELPERS ----------------

  /// Upload an image to Supabase Storage
  /// Returns the public URL of the uploaded file
  Future<String> uploadImage({
    required File file,
    required String bucket,
    required String folder,
    String contentType = 'image/jpeg',
  }) async {
    final fileName = '${const Uuid().v4()}.jpg';
    final path = '$folder/$fileName';

    await supabase.storage.from(bucket).upload(
      path,
      file,
      fileOptions: FileOptions(contentType: contentType, upsert: true),
    );

    return getPublicUrl(bucket, path);
  }

  /// Get the public URL of a file in Supabase Storage
  String getPublicUrl(String bucket, String path) {
    return supabase.storage.from(bucket).getPublicUrl(path);
  }

  /// Delete a file from Supabase Storage
  Future<void> deleteFile(String bucket, String path) async {
    await supabase.storage.from(bucket).remove([path]);
  }

  // ---------------- FETCH SINGLE ROW ----------------

  /// Fetch a single row by column with optional select string
  Future<Map<String, dynamic>?> getRow(
      String table, {
        required String whereColumn,
        required dynamic whereValue,
        String? select,
      }) async {
    final data = await supabase
        .from(table)
        .select(select ?? '*')
        .eq(whereColumn, whereValue)
        .maybeSingle();

    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }
}
