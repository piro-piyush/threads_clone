import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thread_clone/services/auth_service.dart';
import 'package:thread_clone/services/user_service.dart';
import 'package:thread_clone/utils/env.dart';
import 'package:thread_clone/utils/helper.dart';
import 'package:uuid/uuid.dart';

/// EditProfileController manages the complete
/// edit-profile flow.
///
/// Responsibilities:
/// - Initialize user profile data
/// - Track form & image changes
/// - Upload / replace profile image
/// - Update user metadata safely
/// - Handle UI loading & errors
///
/// Built with GetX for reactive updates and
/// Supabase for auth & storage operations.
class EditProfileController extends GetxController {
  /// Auth service to access current user session
  final AuthService authService = Get.find<AuthService>();

  /// User service for profile & storage operations
  final UserService userService = Get.find<UserService>();

  // ---------------- UI CONTROLLERS ----------------

  /// Controller for name input
  late TextEditingController nameController;

  /// Controller for description/bio input
  late TextEditingController descriptionController;

  /// Controller for email input (read-only)
  late TextEditingController emailController;

  // ---------------- INITIAL STATE ----------------

  /// Initial name for change detection
  late String _initialName;

  /// Initial description for change detection
  late String _initialDescription;

  /// Initial profile image URL
  late String _initialImageUrl;

  // ---------------- IMAGE STATE ----------------

  /// Selected new profile image file
  final Rx<File?> selectedImage = Rx<File?>(null);

  /// Current profile image URL
  final Rx<String?> imageUrl = Rx<String?>(null);

  // ---------------- STATE ----------------

  /// Loading state for profile update
  final RxBool isUpdating = false.obs;

  /// Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Current user ID
  String get uid => authService.user!.id;

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

  // ---------------- CHANGE DETECTION ----------------

  /// Checks whether any profile field has changed.
  ///
  /// Used to prevent unnecessary API calls.
  bool hasProfileChanged() {
    final nameChanged = nameController.text.trim() != _initialName;
    final descChanged =
        descriptionController.text.trim() != _initialDescription;

    /// Image considered changed if:
    /// - New image selected
    /// - Existing image URL modified
    final imageChanged =
        (selectedImage.value != null) || (imageUrl.value != _initialImageUrl);

    return nameChanged || descChanged || imageChanged;
  }

  // ---------------- IMAGE PICK ----------------

  /// Picks a profile image from the given source.
  ///
  /// Automatically closes bottom sheet if open.
  Future<void> pickProfileImage(ImageSource source) async {
    final image = await pickImage(source);
    if (image == null) return;

    selectedImage.value = File(image.path);

    if (Get.isBottomSheetOpen == true) Get.back();
  }

  // ---------------- SAVE PROFILE ----------------

  /// Saves profile changes.
  ///
  /// Flow:
  /// 1. Check for changes
  /// 2. Validate form
  /// 3. Upload new image (if any)
  /// 4. Delete old image (if replaced)
  /// 5. Update auth metadata
  /// 6. Sync local state
  Future<void> saveProfile() async {
    if (isUpdating.value) return;

    if (!hasProfileChanged()) {
      Get.snackbar("No changes", "Profile already up to date");
      return;
    }

    if (!formKey.currentState!.validate()) return;

    isUpdating.value = true;

    try {
      String? finalImageUrl = imageUrl.value;

      // ---------- UPLOAD IMAGE IF CHANGED ----------
      if (selectedImage.value != null && selectedImage.value!.existsSync()) {
        final fileName = "${const Uuid().v4()}.jpg";
        final tempPath = "${Directory.systemTemp.path}/$fileName";

        final compressedFile = await compressImage(
          selectedImage.value!,
          tempPath,
        );

        final uploadedUrl = await userService.uploadImage(
          file: compressedFile,
          bucket: Env.s3Bucket,
          folder: 'users/$uid/profile-images',
        );

        /// Delete old image if replaced
        if (_initialImageUrl.isNotEmpty && _initialImageUrl != uploadedUrl) {
          await userService.deleteFile(Env.s3Bucket, _initialImageUrl);
        }

        finalImageUrl = uploadedUrl;
        imageUrl.value = uploadedUrl;
      }

      // ---------- BUILD UPDATE PAYLOAD ----------
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

      // ---------- UPDATE PROFILE ----------
      if (updatedData.isNotEmpty) {
        await userService.updateProfile(updatedData);

        /// Sync local initial state
        _initialName = nameController.text.trim();
        _initialDescription = descriptionController.text.trim();
        _initialImageUrl = finalImageUrl ?? '';
      }

      Get.back();
      showSnackBar("Success", "Profile updated successfully ✅");
    } catch (e, s) {
      debugPrint("❌ Profile save error: $e");
      debugPrintStack(stackTrace: s);
      Get.snackbar("Error", "Failed to update profile ❌");
    } finally {
      isUpdating.value = false;
    }
  }

  // ---------------- CLEANUP ----------------

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
