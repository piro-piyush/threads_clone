import 'package:flutter/material.dart';
import 'package:thread_clone/widgets/circular_image_widget.dart';

class ProfileMetaInfoWidget extends StatelessWidget {
  const ProfileMetaInfoWidget({
    super.key,
    required this.name,
    required this.description,
    this.imageUrl,
  });

  final String name;
  final String description;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        /// Left Column: Name + Description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              // Name
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Description
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        /// Right: Profile Image
        CircularProfileImageWidget(url: imageUrl, radius: 40,
        onTap: (){},),
      ],
    );
  }
}
