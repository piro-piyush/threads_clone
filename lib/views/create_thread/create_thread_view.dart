import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thread_clone/controllers/create_thread_controller.dart';
import 'package:thread_clone/services/supabase_service.dart';

class CreateThreadView extends StatelessWidget {
  const CreateThreadView({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateThreadController controller = Get.put(CreateThreadController());

    return Scaffold(
      appBar: AppBar(
        title: Text("New Thread"),
        leading: CloseButton(),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text("Post", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: controller.userImageUrl.value != null && controller.userImageUrl.value!.isNotEmpty ? NetworkImage(controller.userImageUrl.value!) : const AssetImage('assets/images/avatar.png') as ImageProvider,
                  ),
                  const SizedBox(width: 12),

                  /// Thread input section
                  Expanded(
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(controller.name.value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          const SizedBox(height: 6),

                          TextFormField(
                            controller: controller.controller,
                            maxLength: 1000,
                            maxLines: null,
                            decoration: const InputDecoration(hintText: "Type a thread…", border: InputBorder.none, counterText: ""),
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              IconButton(onPressed: controller.addImage, icon: const Icon(Icons.attach_file)),
                              const SizedBox(width: 8),
                              Text(controller.images.length == 1 ? "1 image" : "${controller.images.length} images", style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              /// ---------------- IMAGE PREVIEW ----------------
              if (controller.images.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.images.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final image = controller.images[index];

                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(image, width: 100, height: 100, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => controller.removeImage(index),
                              child: Container(
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(Icons.close, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}
