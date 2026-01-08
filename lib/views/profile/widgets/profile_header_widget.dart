import 'package:flutter/material.dart';

import 'package:thread_clone/utils/styles/button_styles.dart';
import 'package:thread_clone/views/profile/widgets/profile_meta_info_widget.dart';

class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({super.key, required this.name, required this.description, this.imageUrl, required this.onEditTapped, required this.onShareTapped});

  final String name;
  final String description;
  final String? imageUrl;
  final VoidCallback onEditTapped;
  final VoidCallback onShareTapped;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        ProfileMetaInfoWidget(name: name, description: description, imageUrl: imageUrl),
        Row(
          spacing: 16,
          children: [
            Expanded(
              child: OutlinedButton(onPressed: onEditTapped, style: customOutlineStyle(), child: Text("Edit Profile")),
            ),
            Expanded(
              child: OutlinedButton(onPressed: onShareTapped, style: customOutlineStyle(), child: Text("Share Profile")),
            ),
          ],
        ),
      ],
    );
  }
}
