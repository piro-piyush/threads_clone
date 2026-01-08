import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thread_clone/services/storage_service.dart';
import 'package:thread_clone/utils/env.dart';

class SupabaseService extends GetxService {
  static final SupabaseClient client = Supabase.instance.client;

  final Rx<User?> _currentUser = Rx<User?>(null);

  User? get user => _currentUser.value;

  @override
  void onInit() async {
    super.onInit();
    // Initialize Supabase
    await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseKey);

    // Load user from current session if exists
    _currentUser.value = client.auth.currentUser;

    // Update local storage
    _updateStoredSession(client.auth.currentSession);

    // Listen for auth changes
    listenAuthChanges();
  }

  // Update _currentUser from a stored session
  void updateUserFromSession() {
    final sessionJson = StorageService.userSession;
    if (sessionJson != null) {
      final session = Session.fromJson(sessionJson);
      _currentUser.value = session?.user;
    }
  }

  void listenAuthChanges() {
    client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (session != null) {
        _currentUser.value = session.user;

        // Update local storage whenever auth state changes
        _updateStoredSession(session);
      }

      // Clear local session if signed out
      if (event == AuthChangeEvent.signedOut) {
        _currentUser.value = null;
        StorageService.clearUserSession();
      }
    });
  }

  // ---------------- HELPER ----------------
  void _updateStoredSession(Session? session) {
    if (session != null) {
      StorageService.updateUserSession(session.toJson());
    }
  }
}
