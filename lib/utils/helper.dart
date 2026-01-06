import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
