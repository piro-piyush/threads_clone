import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thread_clone/routes/route_names.dart';
import 'package:thread_clone/services/storage_service.dart';
import 'package:thread_clone/services/supabase_service.dart';
import 'package:thread_clone/utils/helper.dart';
import 'package:thread_clone/utils/storage_keys.dart';

class AuthController extends GetxController {
  final SupabaseClient _client = SupabaseService.supabaseClient;

  // ================== COMMON ==================
  final RxBool isLoading = false.obs;
  final RxBool hidePassword = true.obs;

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  // ================== LOGIN ==================
  late final TextEditingController loginEmailController;
  late final TextEditingController loginPasswordController;

  // ================== REGISTER ==================
  late final TextEditingController nameController;
  late final TextEditingController registerEmailController;
  late final TextEditingController registerPasswordController;
  late final TextEditingController confirmPasswordController;

  @override
  void onInit() {
    super.onInit();

    loginEmailController = TextEditingController();
    loginPasswordController = TextEditingController();

    nameController = TextEditingController();
    registerEmailController = TextEditingController();
    registerPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();

    nameController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    confirmPasswordController.dispose();

    super.onClose();
  }

  void togglePasswordVisibility() {
    hidePassword.value = !hidePassword.value;
  }

  // ================== LOGIN ==================
  Future<void> login() async {
    if (isLoading.value) return;
    if (!loginFormKey.currentState!.validate()) return;

    FocusManager.instance.primaryFocus?.unfocus();

    try {
      isLoading.value = true;

      final res = await _client.auth.signInWithPassword(
        email: loginEmailController.text.trim(),
        password: loginPasswordController.text.trim(),
      );

      if (res.user == null || res.session == null) {
        throw const AuthException('Invalid login credentials');
      }

      await StorageService.storage.write(
        StorageKeys.userSession,
        res.session!.toJson(),
      );

      showSnackBar("Success", "Logged in successfully");
      Get.offAllNamed(RouteNames.home);
    } on AuthException catch (e) {
      showSnackBar("Login Failed", e.message);
    } catch (_) {
      showSnackBar("Error", "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }

  // ================== REGISTER ==================
  Future<void> register() async {
    if (isLoading.value) return;
    if (!registerFormKey.currentState!.validate()) return;

    FocusManager.instance.primaryFocus?.unfocus();

    try {
      isLoading.value = true;

      final res = await _client.auth.signUp(
        email: registerEmailController.text.trim(),
        password: registerPasswordController.text.trim(),
        data: {'name': nameController.text.trim()},
      );

      if (res.user == null) {
        throw const AuthException('Registration failed');
      }

      if (res.session != null) {
        await StorageService.storage.write(
          StorageKeys.userSession,
          res.session!.toJson(),
        );
      }

      showSnackBar("Success", "Account created successfully");
      Get.offAllNamed(RouteNames.login);
    } on AuthException catch (e) {
      showSnackBar("Error", e.message);
    } catch (_) {
      showSnackBar("Error", "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }

  // ================== LOGOUT ==================
  Future<void> logOut() async {
    await _client.auth.signOut();
    await StorageService.storage.remove(StorageKeys.userSession);
    Get.offAllNamed(RouteNames.login);
  }
}
