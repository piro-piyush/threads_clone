import 'dart:io';
import 'package:flutter/material.dart';

class AttachedImageWidget extends StatelessWidget {
  const AttachedImageWidget({super.key, required this.image, required this.onRemove});

  final File image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(image, fit: BoxFit.cover),
        ),

        // ❌ Remove button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black54),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
