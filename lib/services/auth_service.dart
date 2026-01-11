import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thread_clone/services/storage_service.dart';
import 'package:thread_clone/utils/mixins/supabase_mixin.dart';

/// Service responsible for handling authentication and user session.
///
/// Wraps Supabase authentication and provides reactive `user` updates.
/// Also persists session locally using [StorageService].
class AuthService extends GetxService with SupabaseMixin {
  /// Reactive current user
  final Rx<User?> _currentUser = Rx<User?>(null);

  /// Current authenticated user, null if not logged in
  User? get user => _currentUser.value;

  /// Supabase Auth client
  GoTrueClient get auth => supabase.auth;

  @override
  void onInit() {
    super.onInit();

    // 1️⃣ Initialize user from Supabase current session
    _currentUser.value = supabase.auth.currentUser;

    // 2️⃣ Sync session with local storage
    _updateStoredSession(supabase.auth.currentSession);

    // 3️⃣ Start listening to auth state changes
    _listenAuthChanges();
  }

  /// Restore user from locally stored session (if app restarted)
  void updateUserFromSession() {
    final sessionJson = StorageService.userSession;
    if (sessionJson != null) {
      try {
        final session = Session.fromJson(sessionJson);
        _currentUser.value = session?.user;
      } catch (e) {
        // In case of corrupted session, clear it
        StorageService.clearUserSession();
        _currentUser.value = null;
      }
    }
  }

  /// Listen to Supabase auth state changes
  void _listenAuthChanges() {
    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (session != null) {
        _currentUser.value = session.user;
        _updateStoredSession(session);
      }

      if (event == AuthChangeEvent.signedOut) {
        _currentUser.value = null;
        StorageService.clearUserSession();
      }
    });
  }

  // ---------------- HELPER ----------------

  /// Persist the current session to local storage
  void _updateStoredSession(Session? session) {
    if (session != null) {
      StorageService.updateUserSession(session.toJson());
    }
  }
}
