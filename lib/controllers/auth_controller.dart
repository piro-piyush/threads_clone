import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thread_clone/routes/route_names.dart';
import 'package:thread_clone/services/storage_service.dart';
import 'package:thread_clone/services/supabase_service.dart';
import 'package:thread_clone/utils/helper.dart';
import 'package:thread_clone/utils/storage_keys.dart';

class AuthController extends GetxController {
  final registerLoading = false.obs;
  final loginLoading = false.obs;

  // * Register Method
  Future<void> register(String name, String email, String password) async {
    registerLoading.value = true;
    final AuthResponse response = await SupabaseService.client.auth.signUp(email: email, password: password, data: {"name": name});
    registerLoading.value = false;

    if (response.user != null) {
      StorageService.storage.write(StorageKeys.userSession, response.session!.toJson());
      Get.offAllNamed(RouteNames.home);
    } else {
      showSnackBar("Error", "Something went wrong");
    }
  }

  // * Login user
  Future<void> login(String email, String password,BuildContext context) async {
    loginLoading.value = true;
    try {
      final AuthResponse response = await SupabaseService.client.auth.signInWithPassword(email: email, password: password);
      loginLoading.value = false;
      if (response.user != null && response.session != null) {
        StorageService.storage.write(StorageKeys.userSession, response.session!.toJson());
        Get.offAllNamed(RouteNames.home);
        // Navigator.pushNamedAndRemoveUntil(context, RouteNames.home, (route) => false);
      }
    } on AuthException catch (error) {
      loginLoading.value = false;
      showSnackBar("Error", error.message);
    } catch (error) {
      loginLoading.value = false;
      showSnackBar("Error", "Something went wrong.please try again.");
    }
  }
}
