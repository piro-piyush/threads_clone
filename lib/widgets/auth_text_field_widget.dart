import 'package:flutter/material.dart';
import 'package:thread_clone/utils/type_def.dart';

class AuthTextFieldWidget extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final Widget? suffixIcon;
  final ValidatorCallback validatorCallback;
  final bool obscureText;

  const AuthTextFieldWidget({super.key, this.controller, this.obscureText = false, this.labelText, this.hintText, this.suffixIcon, required this.validatorCallback});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validatorCallback,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey),
        ),
        labelText: labelText,
        hintText: hintText,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
