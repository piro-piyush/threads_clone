import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thread_clone/routes/route_names.dart';
import 'package:thread_clone/services/auth_service.dart';
import 'package:thread_clone/services/storage_service.dart';
import 'package:thread_clone/utils/helper.dart';

/// AuthController manages authentication-related
/// actions and UI state using GetX.
///
/// Responsibilities:
/// - User registration
/// - User login
/// - Password change
/// - Loading & error state handling
///
/// This controller acts as a bridge between
/// UI widgets and AuthService (Supabase).
class AuthController extends GetxController {
  /// Loading state for registration flow
  final registerLoading = false.obs;

  /// Loading state for login flow
  final loginLoading = false.obs;

  /// Loading state for password update
  final changingPassword = false.obs;

  /// Auth service instance (dependency injected)
  final AuthService authService = Get.find<AuthService>();

  // ---------------- REGISTER ----------------

  /// Registers a new user using email & password.
  ///
  /// Also attaches additional user metadata (name)
  /// at the time of signup.
  ///
  /// On success:
  /// - Saves session locally
  /// - Redirects user to home screen
  Future<void> register(String name, String email, String password) async {
    registerLoading.value = true;

    final AuthResponse response = await authService.auth.signUp(
      email: email,
      password: password,
      data: {"name": name},
    );

    registerLoading.value = false;

    if (response.user != null && response.session != null) {
      StorageService.setUserSession(response.session!.toJson());
      Get.offAllNamed(RouteNames.home);
    } else {
      showSnackBar("Error", "Something went wrong");
    }
  }

  // ---------------- LOGIN ----------------

  /// Logs in an existing user using email & password.
  ///
  /// On success:
  /// - Saves session locally
  /// - Redirects user to home screen
  ///
  /// Handles both AuthException and generic errors.
  Future<void> login(String email, String password) async {
    loginLoading.value = true;

    try {
      final AuthResponse response =
      await authService.auth.signInWithPassword(
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
    } catch (e) {
      loginLoading.value = false;
      showSnackBar("Error", e.toString());
    }
  }

  // ---------------- CHANGE PASSWORD ----------------

  /// Updates password for the currently logged-in user.
  ///
  /// Prevents multiple simultaneous requests
  /// using a local loading guard.
  Future<void> changePassword(String newPassword) async {
    if (changingPassword.value) return;
    changingPassword.value = true;

    try {
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
