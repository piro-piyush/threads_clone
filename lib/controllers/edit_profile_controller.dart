import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thread_clone/utils/helper.dart';
import 'package:uuid/uuid.dart';

class EditProfileController extends GetxController {
  final Rx<File?> selectedImage = Rx<File?>(null);
  final Rx<String?> imageUrl = Rx<String?>(null);
  final RxBool isUploading = false.obs;
  final RxBool isUpdating = false.obs;

  Future<void> pickAndUpload(ImageSource source) async {
    isUploading.value = true;

    try {
      final image = await pickImage(source);
      if (image == null) return;

      final originalFile = File(image.path);
      selectedImage.value = originalFile;

      final tempDir = Directory.systemTemp;
      final fileName = "${const Uuid().v4()}.jpg";
      final compressedPath = "${tempDir.path}/$fileName";

      final compressedFile = await compressImage(
        originalFile,
        compressedPath,
      );

      final uploadedPath = await uploadImageToSupabase(
        file: compressedFile,
        bucketName: 'threads_s3',
        folder: 'users/profile-images',
      );

      imageUrl.value = uploadedPath;
    } catch (e, s) {
      debugPrint("❌ Image pick/upload error: $e");
      debugPrintStack(stackTrace: s);

      showSnackBar(
        "Upload failed",
        "Please try again",
      );
    } finally {
      isUploading.value = false;
      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }
    }
  }

  Future<void> updateProfile(String userId, String name, String description) async {
    try{
      isUploading.value = true;
      await Supabase.instance.client.from('users').update({
        'name': name,
        'description': description,
        'image_url': imageUrl.value
      });
    }catch(e,s){
      debugPrint("❌ Update profile error: $e");
      debugPrintStack(stackTrace: s);

      showSnackBar(
        "Upload failed",
        "Please try again",
      );
    } finally{
      isUploading.value = false;
    }
  }
}
