import 'dart:io';
import 'package:flutter/material.dart';
import 'package:thread_clone/views/create_thread/widgets/attached_image_widget.dart';

class AttachedImagesListWidget extends StatelessWidget {
  const AttachedImagesListWidget({super.key, required this.images, required this.onRemove});

  final List<File> images;
  final Function(int) onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final image = images[index];
          return AttachedImageWidget(image: image, onRemove: () => onRemove(index));
        },
      ),
    );
  }
}
