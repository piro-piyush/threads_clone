import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thread_clone/services/supabase_service.dart';
import 'package:thread_clone/utils/helper.dart';
import 'package:uuid/uuid.dart';

class CreateThreadController extends GetxController {
  final SupabaseService supabaseService = Get.find<SupabaseService>();

  // Reactive user data
  RxString name = ''.obs;
  RxnString userImageUrl = RxnString(null);

  // Thread content
  final TextEditingController controller = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Images attached to the thread
  final RxList<File> images = <File>[].obs;

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize reactive user info
    name.value = supabaseService.user?.userMetadata?['name'] ?? '';
    userImageUrl.value = supabaseService.user?.userMetadata?['image_url'] ?? '';
  }

  // ---------------- IMAGE MANAGEMENT ----------------
  void addImage() async {
    final source = await openImagePickerSheet();
    if (source != null) {
      final pickedImage = await pickImage(source);
      if (pickedImage != null) {
        images.add(File(pickedImage.path));
      }
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < images.length) {
      images.removeAt(index);
    }
  }

  // ---------------- THREAD VALIDATION ----------------
  String? validateThread(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Thread content cannot be empty";
    }
    if (value.trim().length > 500) {
      return "Thread content cannot exceed 500 characters";
    }
    return null;
  }

  // ---------------- CREATE THREAD ----------------
  Future<void> createThread() async {
    if (isLoading.value) return;
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final uid = supabaseService.user!.id;
      final threadId = const Uuid().v4();

      // TODO: handle image uploads if images are added
      List<String> uploadedImageUrls = [];
      // Example: await uploadImageToSupabase(images[i], ...)

      // Save thread data in Supabase (replace 'threads' with your table)
      final response = await SupabaseService.client.from('threads').insert({'id': threadId, 'user_id': uid, 'content': controller.text.trim(), 'images': uploadedImageUrls, 'created_at': DateTime.now().toIso8601String()});

      if (response.error != null) {
        throw response.error!;
      }

      // Clear input after success
      controller.clear();
      images.clear();

      Get.snackbar("Success", "Thread created successfully ✅");
    } catch (e) {
      debugPrint("Error creating thread: $e");
      Get.snackbar("Error", "Failed to create thread ❌");
    } finally {
      isLoading.value = false;
    }
  }
}
