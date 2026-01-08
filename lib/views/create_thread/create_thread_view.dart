import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thread_clone/controllers/create_thread_controller.dart';
import 'package:thread_clone/views/create_thread/widgets/input_section_widget.dart';

import 'widgets/attached_images_list_widget.dart';

class CreateThreadView extends StatelessWidget {
  const CreateThreadView({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateThreadController controller = Get.put(CreateThreadController());

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("New Thread"),
          leading: CloseButton(),
          actions: [
            TextButton(
              onPressed: controller.createThread,
              child: Text("Post", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                InputSectionWidget(
                  userImageUrl: controller.userImageUrl.value,
                  controller: controller.controller,
                  formKey: controller.formKey,
                  name: controller.name.value,
                  onAddClicked: controller.addImage,
                  imagesLength: controller.images.length,
                ),

                /// ---------------- IMAGE PREVIEW ----------------
                if (controller.images.isNotEmpty) ...[AttachedImagesListWidget(images: controller.images, onRemove: (index) => controller.removeImage(index))],
              ],
            );
          }),
        ),
      ),
    );
  }
}
