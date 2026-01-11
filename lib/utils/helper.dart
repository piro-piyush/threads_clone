import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thread_clone/widgets/picker_tile_widget.dart';

/// ---------------- SHOW SNACKBAR ----------------
/// A convenient function to show a bottom snackbar
void showSnackBar(String title, String message) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: const Color(0xFF252526),
    margin: EdgeInsets.zero,
    colorText: Colors.white,
    snackStyle: SnackStyle.GROUNDED,
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
  );
}

/// ---------------- IMAGE PICKER SHEET ----------------
/// Opens a bottom sheet allowing user to pick image from Camera or Gallery
Future<ImageSource?> openImagePickerSheet() async {
  return await Get.bottomSheet<ImageSource>(
    Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: Colors.grey[900],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PickerTileWidget(
              icon: Icons.camera_alt,
              title: "Take Photo",
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            PickerTileWidget(
              icon: Icons.photo_library,
              title: "Choose from Gallery",
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
            const Divider(color: Colors.grey),
            PickerTileWidget(
              icon: Icons.close,
              title: "Cancel",
              onTap: () => Get.back(), // returns null
            ),
          ],
        ),
      ),
    ),
  );
}

/// ---------------- PICK IMAGE ----------------
/// Picks a single image from the given source
/// `quality` ranges 0-100 to reduce image size
Future<XFile?> pickImage(ImageSource source, {int quality = 80}) async {
  final ImagePicker picker = ImagePicker();

  try {
    return await picker.pickImage(source: source, imageQuality: quality);
  } catch (e) {
    debugPrint("❌ Pick image error: $e");
    return null;
  }
}

/// ---------------- COMPRESS IMAGE ----------------
/// Compresses a file and saves it to `outputPath`
/// Returns a [File] pointing to the compressed image
Future<File> compressImage(
    File file,
    String outputPath, {
      int quality = 70,
    }) async {
  final result = await FlutterImageCompress.compressAndGetFile(
    file.path,
    outputPath,
    quality: quality,
  );

  if (result == null) {
    throw Exception("Image compression failed");
  }

  return File(result.path);
}
