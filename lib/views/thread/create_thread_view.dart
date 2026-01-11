import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thread_clone/controllers/create_thread_controller.dart';
import 'package:thread_clone/services/navigation_service.dart';
import 'package:thread_clone/views/thread/widgets/input_section_widget.dart';
import 'package:thread_clone/widgets/status_loader_widget.dart';

class CreateThreadView extends StatelessWidget {
  const CreateThreadView({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateThreadController controller = Get.put(CreateThreadController());

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("New Thread"),
          leading: CloseButton(onPressed: Get.find<NavigationService>().backToPrevIndex),
          actions: [
            Obx(() {
              if (controller.isLoading.value) {
                return SizedBox.shrink();
              }
              return TextButton(
                onPressed: controller.createThread,
                child: Text("Post", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              );
            }),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return StatusLoaderWidget(title: "Uploading", subtitle: "Please wait a moment, uploading your thread", icon: Icons.upload);
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: InputSectionWidget(
              userImageUrl: controller.userImageUrl.value,
              controller: controller.controller,
              formKey: controller.formKey,
              name: controller.name.value,
              onAddClicked: controller.addImage,
              image: controller.image.value,
              onRemove: controller.removeImage,
            ),
          );
        }),
      ),
    );
  }
}
