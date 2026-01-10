import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thread_clone/models/searched_user_model.dart';
import 'package:thread_clone/routes/route_names.dart';
import 'package:thread_clone/widgets/circular_image_widget.dart';

class UserTileWidget extends StatelessWidget {
  const UserTileWidget({super.key, required this.user});

  final SearchedUserModel user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: CircularProfileImageWidget(
          url: user.metadata?.imageUrl,radius: 28,
          uid:user.id,
        ),
      ),
      title: Text(user.metadata!.name),
      titleAlignment: ListTileTitleAlignment.top,
      trailing: OutlinedButton(
        onPressed: () {
          Get.toNamed(RouteNames.showProfile, arguments: user.id);
        },
        child: const Text("View profile"),
      ),
      subtitle: Text(user.formattedCreatedAt),
    );
  }
}
