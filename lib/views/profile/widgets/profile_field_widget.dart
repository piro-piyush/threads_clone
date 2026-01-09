import 'package:flutter/material.dart';
import 'package:thread_clone/utils/type_def.dart';

class ProfileFieldWidget extends StatelessWidget {
  final String label;
  final String hint;
  final int maxLines;
  final bool readOnly;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final ValidatorCallback validatorCallback;

  const ProfileFieldWidget({required this.label, required this.hint, this.maxLines = 1, this.keyboardType = TextInputType.text, required this.readOnly, this.controller, required this.validatorCallback});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme
            .of(context)
            .textTheme
            .bodySmall
            ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        TextFormField(
          maxLines: maxLines,
          readOnly: readOnly,
          controller: controller,
          keyboardType: keyboardType,
          validator: validatorCallback,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}
