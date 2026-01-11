import 'package:get_storage/get_storage.dart';
import 'package:thread_clone/utils/storage_keys.dart';

/// A centralized service to manage local persistent storage using GetStorage.
class StorageService {
  static final GetStorage _storage = GetStorage();

  // ---------------- GENERIC STORAGE ----------------

  /// Saves a [value] for a given [key].
  static Future<void> save(String key, dynamic value) async {
    try {
      await _storage.write(key, value);
    } catch (e, st) {
      print('Error saving key "$key": $e\n$st');
      rethrow; // propagate error
    }
  }

  /// Reads a value of type [T] from storage.
  /// Returns null if the key doesn't exist or type mismatches.
  static T? read<T>(String key) {
    try {
      final value = _storage.read(key);
      if (value is T) return value;
      return null;
    } catch (e, st) {
      print('Error reading key "$key": $e\n$st');
      return null;
    }
  }

  /// Updates an existing [key] with [value], or creates it if it doesn't exist.
  static Future<void> update(String key, dynamic value) async {
    try {
      if (_storage.hasData(key)) {
        await _storage.write(key, value);
      } else {
        await save(key, value);
      }
    } catch (e, st) {
      print('Error updating key "$key": $e\n$st');
      rethrow;
    }
  }

  /// Deletes a value from storage.
  static Future<void> delete(String key) async {
    try {
      if (_storage.hasData(key)) {
        await _storage.remove(key);
      }
    } catch (e, st) {
      print('Error deleting key "$key": $e\n$st');
      rethrow;
    }
  }

  /// Checks if a given [key] exists in storage.
  static bool contains(String key) {
    try {
      return _storage.hasData(key);
    } catch (e, st) {
      print('Error checking key "$key": $e\n$st');
      return false;
    }
  }

  /// Clears all stored data.
  static Future<void> clear() async {
    try {
      await _storage.erase();
    } catch (e, st) {
      print('Error clearing storage: $e\n$st');
      rethrow;
    }
  }

  // ---------------- USER SESSION HELPERS ----------------

  static dynamic get userSession => read(StorageKeys.userSession);

  static Future<void> setUserSession(dynamic session) =>
      save(StorageKeys.userSession, session);

  static Future<void> updateUserSession(dynamic session) =>
      update(StorageKeys.userSession, session);

  static Future<void> clearUserSession() => delete(StorageKeys.userSession);

  static bool get isLoggedIn => contains(StorageKeys.userSession);
}
