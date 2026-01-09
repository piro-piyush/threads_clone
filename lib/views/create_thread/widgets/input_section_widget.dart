import 'dart:io';

import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:thread_clone/views/create_thread/widgets/attached_images_list_widget.dart';
import 'package:thread_clone/widgets/circular_image_widget.dart';

class InputSectionWidget extends StatelessWidget {
  const InputSectionWidget({
    super.key,
    required this.formKey,
    required this.controller,
    required this.name,
    required this.onAddClicked,
    this.userImageUrl,
    this.image,
    required this.onRemove,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final String name;

  final VoidCallback onAddClicked;
  final String? userImageUrl;
  final File? image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        CircularProfileImageWidget(url: userImageUrl, radius: 28),

        /// Thread input section
        Expanded(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                    ),

                    TextFormField(
                      controller: controller,
                      maxLength: 1000,
                      minLines: 1,
                      maxLines: 10,
                      validator: ValidationBuilder()
                          .required()
                          .maxLength(1000)
                          .build(),
                      decoration: const InputDecoration(
                        hintText: "Type a thread…",
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),

                IconButton(
                  onPressed: onAddClicked,
                  icon: const Icon(Icons.attach_file),
                ),

                /// ---------------- IMAGE PREVIEW ----------------
                if (image != null) ...[
                  AttachedImageWidget(image: image!, onRemove: onRemove),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
