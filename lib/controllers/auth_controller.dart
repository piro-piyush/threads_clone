import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thread_clone/routes/route_names.dart';
import 'package:thread_clone/services/auth_service.dart';
import 'package:thread_clone/services/storage_service.dart';
import 'package:thread_clone/utils/helper.dart';

class AuthController extends GetxController {
  final registerLoading = false.obs;
  final loginLoading = false.obs;
  final changingPassword = false.obs;

  final AuthService authService = Get.find<AuthService>();

  // * Register Method
  Future<void> register(String name, String email, String password) async {
    registerLoading.value = true;
    final AuthResponse response = await authService.auth.signUp(
      email: email,
      password: password,
      data: {"name": name},
    );
    registerLoading.value = false;

    if (response.user != null) {
      StorageService.setUserSession(response.session!.toJson());
      Get.offAllNamed(RouteNames.home);
    } else {
      showSnackBar("Error", "Something went wrong");
    }
  }

  // * Login user
  Future<void> login(String email, String password) async {
    loginLoading.value = true;
    try {
      final AuthResponse response = await authService.auth.signInWithPassword(
        email: email,
        password: password,
      );
      loginLoading.value = false;
      if (response.user != null && response.session != null) {
        StorageService.setUserSession(response.session!.toJson());
        Get.offAllNamed(RouteNames.home);
      }
    } on AuthException catch (error) {
      loginLoading.value = false;
      showSnackBar("Error", error.message);
    } catch (error) {
      loginLoading.value = false;
      showSnackBar("Error", "Something went wrong.please try again.");
    }
  }

  Future<void> changePassword(String newPassword) async {
    if (changingPassword.value) return;
    changingPassword.value = true;

    try {
      // Update password directly for logged-in user
      await authService.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      Get.snackbar("Success", "Password updated successfully");
    } on AuthException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (e) {
      Get.snackbar("Error", "Failed to change password: $e");
    } finally {
      changingPassword.value = false;
    }
  }




}
