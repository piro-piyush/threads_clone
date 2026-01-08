import 'dart:io';

import 'package:flutter/material.dart';

class ProfileImageWidget extends StatelessWidget {
  const ProfileImageWidget({super.key, this.image, this.imageUrl, required this.radius});

  final File? image;
  final String? imageUrl;
  final double radius;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).dividerColor, width: 2),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundImage: image != null
            ? FileImage(image!)
            : imageUrl != null
            ? NetworkImage(imageUrl!)
            : const AssetImage('assets/images/avatar.png') as ImageProvider,
      ),
    );
  }
}
