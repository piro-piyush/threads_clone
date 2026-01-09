import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:thread_clone/controllers/auth_controller.dart';
import 'package:thread_clone/widgets/auth_text_field_widget.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final AuthController controller = Get.find<AuthController>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late final TextEditingController newPasswordController;

  bool hidePassword = true;

  @override
  void initState() {
    super.initState();
    newPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    super.dispose();
  }

  void submit() {
    if (formKey.currentState!.validate()) {
      controller.changePassword(newPasswordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                /// NEW PASSWORD
                AuthTextFieldWidget(
                  controller: newPasswordController,
                  labelText: "New Password",
                  hintText: "Enter new password",
                  obscureText: hidePassword,
                  validatorCallback: ValidationBuilder()
                      .required()
                      .minLength(6)
                      .build(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      hidePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => hidePassword = !hidePassword),
                  ),
                ),

                const SizedBox(height: 30),

                /// SUBMIT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: Obx(() {
                    return ElevatedButton(
                      onPressed: controller.changingPassword.value
                          ? null
                          : submit,
                      child: controller.changingPassword.value
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text("Update Password"),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
