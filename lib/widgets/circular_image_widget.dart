import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:thread_clone/routes/route_names.dart';

class CircularProfileImageWidget extends StatelessWidget {
  const CircularProfileImageWidget({super.key, this.url, this.radius = 28, this.uid});

  final String? url;
  final double radius;
  final String? uid;
  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: const AssetImage('assets/images/avatar.png'),
      );
    }

    return InkWell(
      onTap: () {
        Get.toNamed(RouteNames.showProfile, arguments: uid);
      },
      child: ClipOval(
        child: ExtendedImage.network(
          url!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          cache: true,
          loadStateChanged: (state) {
            switch (state.extendedImageLoadState) {
              case LoadState.loading:
                return Shimmer.fromColors(
                  baseColor: Colors.grey[850]!,
                  highlightColor: Colors.grey[700]!,
                  period: const Duration(milliseconds: 1200),
                  child: Container(
                    width: radius * 2,
                    height: radius * 2,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              case LoadState.failed:
                return Container(
                  width: radius * 2,
                  height: radius * 2,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white),
                );
              case LoadState.completed:
                return ExtendedRawImage(
                  image: state.extendedImageInfo?.image,
                  width: radius * 2,
                  height: radius * 2,
                  fit: BoxFit.cover,
                );
            }
          },
        ),
      ),
    );
  }
}
