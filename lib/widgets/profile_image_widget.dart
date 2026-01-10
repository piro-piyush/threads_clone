import 'dart:io';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:thread_clone/routes/route_names.dart';

class ProfileImageWidget extends StatelessWidget {
  const ProfileImageWidget({
    super.key,
    this.image,
    this.imageUrl,
    required this.id,
    required this.uid,
    required this.radius,
  });

  final File? image;
  final String? imageUrl;
  final double radius;
  final String id;
  final String uid;

  @override
  Widget build(BuildContext context) {
    Widget avatar;

    if (image != null) {
      // Local file image
      avatar = CircleAvatar(radius: radius, backgroundImage: FileImage(image!));
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      // Network image with caching and shimmer
      avatar = ClipOval(
        child: ExtendedImage.network(
          imageUrl!,
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
      );
    } else {
      // Default asset
      avatar = CircleAvatar(
        radius: radius,
        backgroundImage: const AssetImage('assets/images/avatar.png'),
      );
    }

    return InkWell(
      onTap: () {
        Get.toNamed(RouteNames.showProfile, arguments: uid);
      },
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).dividerColor, width: 2),
        ),
        child: avatar,
      ),
    );
  }
}
