import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extended_image/extended_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:thread_clone/routes/route_names.dart';

class ThreadCardImageWidget extends StatelessWidget {
  const ThreadCardImageWidget({super.key, this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const SizedBox();
    }

    return InkWell(
      onTap: () {
        Get.toNamed(RouteNames.fullScreenImage, arguments: imageUrl);
      },
      child: ConstrainedBox(
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
      ),
    );
  }
}
