import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:thread_clone/controllers/edit_profile_controller.dart';
import 'package:thread_clone/utils/helper.dart';
import 'package:thread_clone/views/profile/widgets/profile_field_widget.dart';
import 'package:thread_clone/widgets/status_loader_widget.dart';
import 'package:thread_clone/widgets/profile_image_widget.dart';

class EditProfileView extends StatelessWidget {
  EditProfileView({super.key});

  final controller = Get.put(EditProfileController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
        actions: [
          Obx(() {
            if (controller.isUpdating.value) {
              return SizedBox.shrink();
            }
            return TextButton(
              onPressed: controller.saveProfile,
              child: const Text(
                "Save",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isUpdating.value) {
          return const StatusLoaderWidget(
            icon: Icons.sync_rounded,
            title: "Updating Profile",
            subtitle: "Please wait, saving your changes",
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Avatar Section
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ProfileImageWidget(
                        image: controller.selectedImage.value,
                        radius: 70,
                        imageUrl: controller.imageUrl.value,
                      ),
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () async {
                            final source = await openImagePickerSheet();
                            if (source != null) {
                              controller.pickProfileImage(source);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                /// Form Fields
                ProfileFieldWidget(
                  label: "Name",
                  hint: "Your name",
                  readOnly: false,
                  controller: controller.nameController,
                  validatorCallback: ValidationBuilder()
                      .required()
                      .minLength(2)
                      .maxLength(50)
                      .build(),
                ),
                const SizedBox(height: 16),

                ProfileFieldWidget(
                  label: "Email",
                  hint: "your@email.com",
                  keyboardType: TextInputType.emailAddress,
                  readOnly: true,
                  controller: controller.emailController,
                  validatorCallback: ValidationBuilder()
                      .required()
                      .email()
                      .build(),
                ),
                const SizedBox(height: 16),

                ProfileFieldWidget(
                  label: "Description",
                  hint: "Write something about you",
                  maxLines: 5,

                  readOnly: false,
                  controller: controller.descriptionController,
                  validatorCallback: (val) {
                    if (val == null || val.isEmpty) {
                      return null;
                    }
                    if (val.length > 100) {
                      return "Description cannot be more than 100 characters";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
