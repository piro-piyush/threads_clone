import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extended_image/extended_image.dart';

class FullScreenImageView extends StatelessWidget {
  FullScreenImageView({super.key});

  final String url = Get.arguments as String;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ExtendedImage.network(
        url,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        cache: true,
        mode: ExtendedImageMode.gesture,
        initGestureConfigHandler: (_) => GestureConfig(
          minScale: 1.0,
          maxScale: 4.0,
          animationMinScale: 0.8,
          animationMaxScale: 4.5,
          speed: 1.0,
          inertialSpeed: 100.0,
          initialScale: 1.0,
        ),
        loadStateChanged: (state) {
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              return const Center(child: CircularProgressIndicator());
            case LoadState.failed:
              return const Center(
                child: Icon(Icons.broken_image, color: Colors.white, size: 40),
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}
