import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

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

Future<String> uploadImageToSupabase({required File file, required String bucketName, required String folder, String contentType = 'image/jpeg'}) async {
  final uuid = const Uuid();
  final fileName = "${uuid.v4()}.jpg";
  final filePath = '$folder/$fileName';

  await Supabase.instance.client.storage.from(bucketName).upload(filePath, file, fileOptions: FileOptions(upsert: true, contentType: contentType,));

  return filePath;
}
