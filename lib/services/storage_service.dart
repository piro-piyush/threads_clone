import 'package:get_storage/get_storage.dart';
import 'package:thread_clone/utils/storage_keys.dart';

class StorageService {
  static final GetStorage _storage = GetStorage();

  /// Save a value to storage
  static Future<void> save(String key, dynamic value) async {
    await _storage.write(key, value);
  }

  /// Read a value from storage
  static T? read<T>(String key) {
    final value = _storage.read(key);
    if (value is T) return value;
    return null;
  }

  /// Update an existing value (or create if not exists)
  static Future<void> update(String key, dynamic value) async {
    if (_storage.hasData(key)) {
      await _storage.write(key, value);
    } else {
      await save(key, value);
    }
  }

  /// Delete a value from storage
  static Future<void> delete(String key) async {
    if (_storage.hasData(key)) {
      await _storage.remove(key);
    }
  }

  /// Check if a key exists
  static bool contains(String key) {
    return _storage.hasData(key);
  }

  /// Clear all storage
  static Future<void> clear() async {
    await _storage.erase();
  }

  /// User session helper
  static dynamic get userSession => read(StorageKeys.userSession);
  static Future<void> setUserSession(dynamic session) => save(StorageKeys.userSession, session);
  static Future<void> updateUserSession(dynamic session) => update(StorageKeys.userSession, session);
  static Future<void> clearUserSession() => delete(StorageKeys.userSession);
  static bool get isLoggedIn => contains(StorageKeys.userSession);

}
