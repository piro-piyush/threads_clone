import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:extended_image/extended_image.dart';
import 'package:shimmer/shimmer.dart';

class ThreadCardImageWidget extends StatelessWidget {
  const ThreadCardImageWidget({super.key, this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const SizedBox(); // No image
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: context.height * 0.6,
        maxWidth: context.width * 0.8,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ExtendedImage.network(
          imageUrl!,
          fit: BoxFit.cover,
          cache: true, // ✅ caching enabled
          borderRadius: BorderRadius.circular(20),
          loadStateChanged: (state) {
            switch (state.extendedImageLoadState) {
              case LoadState.loading:
                return Shimmer.fromColors(
                  baseColor: Colors.grey[850]!,
                  highlightColor: Colors.grey[700]!,
                  period: const Duration(milliseconds: 1200),
                  child: Container(color: Colors.grey[850]),
                );
              case LoadState.failed:
                return Container(
                  color: Colors.grey[850],
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 40,
                      color: Colors.white54,
                    ),
                  ),
                );
              case LoadState.completed:
                return ExtendedRawImage(
                  image: state.extendedImageInfo?.image,
                  fit: BoxFit.cover,
                );
            }
          },
        ),
      ),
    );
  }
}
