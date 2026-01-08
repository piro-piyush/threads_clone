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
    await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseKey);
    _currentUser.value = client.auth.currentUser;
    listenAuthChanges();
  }

  // * first load the status
  void updateUserFromSession() {
    var session = Session.fromJson(StorageService.userSession!);
    _currentUser.value = session?.user;
  }

  void listenAuthChanges() {
    client.auth.onAuthStateChange.listen((state) {
      final event = state.event;
      if (event == AuthChangeEvent.userUpdated) {
        _currentUser.value = state.session?.user;
      } else if (event == AuthChangeEvent.signedIn) {
        _currentUser.value = state.session?.user;
      }
    });
  }
}
