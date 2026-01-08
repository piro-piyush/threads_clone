import 'package:flutter/material.dart';

class InputSectionWidget extends StatelessWidget {
  const InputSectionWidget({super.key, required this.formKey, required this.controller, required this.name, required this.onAddClicked, required this.imagesLength, this.userImageUrl});

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final String name;

  final VoidCallback onAddClicked;
  final int imagesLength;
  final String? userImageUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        CircleAvatar(radius: 28, backgroundImage: userImageUrl != null && userImageUrl!.isNotEmpty ? NetworkImage(userImageUrl!) : const AssetImage('assets/images/avatar.png') as ImageProvider),

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
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16), maxLines: 1),

                    TextFormField(
                      controller: controller,
                      maxLength: 1000,
                      maxLines: null,
                      decoration: const InputDecoration(hintText: "Type a thread…", border: InputBorder.none, counterText: ""),
                    ),
                  ],
                ),

                Row(
                  spacing: 6,
                  children: [
                    IconButton(onPressed: onAddClicked, icon: const Icon(Icons.attach_file)),
                    Text(imagesLength == 1 ? "1 image" : "$imagesLength images", style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
