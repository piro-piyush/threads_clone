import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thread_clone/services/auth_service.dart';
import 'package:thread_clone/services/user_service.dart';
import 'package:thread_clone/utils/env.dart';
import 'package:thread_clone/utils/helper.dart';
import 'package:uuid/uuid.dart';

class EditProfileController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final UserService userService = Get.find<UserService>();


  // UI Controllers (ONLY HERE)
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController emailController;

  // Initial values (for change detection)
  late String _initialName;
  late String _initialDescription;
  late String _initialImageUrl;

  // Image state
  final Rx<File?> selectedImage = Rx<File?>(null);
  final Rx<String?> imageUrl = Rx<String?>(null);

  final RxBool isUpdating = false.obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // ---------------- INIT ----------------
  @override
  void onInit() {
    super.onInit();

    final metadata = authService.user?.userMetadata ?? {};

    _initialName = metadata['name'] ?? '';
    _initialDescription = metadata['description'] ?? '';
    _initialImageUrl = metadata['image_url'] ?? '';

    nameController = TextEditingController(text: _initialName);
    descriptionController = TextEditingController(text: _initialDescription);
    emailController = TextEditingController(text: metadata['email'] ?? '');

    imageUrl.value = _initialImageUrl;
  }

  // ---------------- CHANGE CHECK ----------------
  bool hasProfileChanged() {
    final nameChanged = nameController.text.trim() != _initialName;
    final descChanged = descriptionController.text.trim() != _initialDescription;

    // 🔹 Image changed if new file selected or URL changed
    final imageChanged = (selectedImage.value != null) || (imageUrl.value != _initialImageUrl);

    return nameChanged || descChanged || imageChanged;
  }

  // ---------------- IMAGE PICK ----------------
  Future<void> pickProfileImage(ImageSource source) async {
    final image = await pickImage(source);
    if (image == null) return;

    selectedImage.value = File(image.path);

    if (Get.isBottomSheetOpen == true) Get.back();
  }

  // ---------------- SAVE PROFILE ----------------
  Future<void> saveProfile() async {
    if (isUpdating.value) return;

    if (!hasProfileChanged()) {
      Get.snackbar("No changes", "Profile already up to date");
      return;
    }

    if (!formKey.currentState!.validate()) return;

    isUpdating.value = true;

    try {
      final uid = authService.user!.id;
      String? finalImageUrl = imageUrl.value;

      // ---------------- UPLOAD IMAGE IF NEW ----------------
      if (selectedImage.value != null && selectedImage.value!.existsSync()) {
        final fileName = "${const Uuid().v4()}.jpg";
        final tempPath = "${Directory.systemTemp.path}/$fileName";

        final compressedFile = await compressImage(selectedImage.value!, tempPath);

        final uploadedUrl = await userService.uploadImage(file: compressedFile, bucket: Env.s3Bucket, folder: 'users/$uid/profile-images');

        // Delete old image if exists
        if (_initialImageUrl.isNotEmpty && _initialImageUrl != uploadedUrl) {
          await userService.deleteFile(Env.s3Bucket, _initialImageUrl);
        }

        finalImageUrl = uploadedUrl;
        imageUrl.value = uploadedUrl;
      }

      // ---------------- ONLY UPDATE IF DATA CHANGED ----------------
      final Map<String, dynamic> updatedData = {};

      if (_initialName != nameController.text.trim()) {
        updatedData['name'] = nameController.text.trim();
      }
      if (_initialDescription != descriptionController.text.trim()) {
        updatedData['description'] = descriptionController.text.trim();
      }
      if (_initialImageUrl != finalImageUrl) {
        updatedData['image_url'] = finalImageUrl;
      }

      if (updatedData.isNotEmpty) {
        // Update via Supabase Auth user metadata
        await userService.updateProfile(updatedData);
        // await authService.supabase.auth.updateUser(UserAttributes(data: updatedData));

        // Update local initial values
        _initialName = nameController.text.trim();
        _initialDescription = descriptionController.text.trim();
        _initialImageUrl = finalImageUrl ?? '';
      }

      Get.back();
      showSnackBar("Success", "Profile updated successfully ✅");
    } on StorageException catch (e) {
      debugPrint("❌ Storage error: $e");
      Get.snackbar("Error", "Failed to upload image ❌");
    } on AuthException catch (e) {
      debugPrint("❌ Auth error: $e");
      Get.snackbar("Error", "Failed to update profile ❌");
    } catch (e, s) {
      debugPrint("❌ Profile save error: $e");
      debugPrintStack(stackTrace: s);
      Get.snackbar("Error", "Failed to update profile ❌");
    } finally {
      isUpdating.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    emailController.dispose();
    super.onClose();
  }


}
