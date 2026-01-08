import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thread_clone/widgets/picker_tile_widget.dart';

void showSnackBar(String title, String message) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Color(0xFF252526),
    margin: EdgeInsets.all(0.0),
    colorText: Colors.white,
    snackStyle: SnackStyle.GROUNDED,
    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
  );
}

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
            const Divider(),
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

Future<XFile?> pickImage(ImageSource source, {int quality = 80}) async {
  final ImagePicker picker = ImagePicker();

  try {
    return await picker.pickImage(source: source, imageQuality: quality);
  } catch (e) {
    debugPrint("❌ Pick image error: $e");
    return null;
  }
}

Future<File> compressImage(File file, String outputPath, {int quality = 70}) async {
  final result = await FlutterImageCompress.compressAndGetFile(file.path, outputPath, quality: quality);

  if (result == null) {
    throw Exception("Image compression failed");
  }

  return File(result.path);
}

