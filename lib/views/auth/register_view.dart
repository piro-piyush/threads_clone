import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:thread_clone/controllers/auth_controller.dart';
import 'package:thread_clone/routes/route_names.dart';
import 'package:thread_clone/widgets/auth_text_field_widget.dart';

class RegisterView extends StatelessWidget {
  RegisterView({super.key});

  final AuthController controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: controller.registerFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Image.asset("assets/images/logo.png", width: 60, height: 60)),

                  const SizedBox(height: 20),

                  const Text("Register", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  const Text("Welcome to the threads world"),

                  const SizedBox(height: 20),

                  /// NAME
                  AuthTextFieldWidget(controller: controller.nameController, labelText: "Name", hintText: "Enter name", validatorCallback: ValidationBuilder().required().minLength(2).maxLength(50).build()),

                  const SizedBox(height: 20),

                  /// EMAIL
                  AuthTextFieldWidget(controller: controller.registerEmailController, labelText: "Email", hintText: "Enter email", validatorCallback: ValidationBuilder().required().email().build()),

                  const SizedBox(height: 20),

                  /// PASSWORD
                  Obx(() {
                    return AuthTextFieldWidget(
                      controller: controller.registerPasswordController,
                      labelText: "Password",
                      hintText: "Enter password",
                      obscureText: controller.hidePassword.value,
                      validatorCallback: ValidationBuilder(requiredMessage: "Password is required").required().minLength(6).maxLength(20).build(),
                      suffixIcon: IconButton(icon: Icon(controller.hidePassword.value ? Icons.visibility_off : Icons.visibility), onPressed: controller.togglePasswordVisibility),
                    );
                  }),

                  const SizedBox(height: 20),

                  /// CONFIRM PASSWORD
                  Obx(() {
                    return AuthTextFieldWidget(
                      controller: controller.confirmPasswordController,
                      labelText: "Confirm Password",
                      hintText: "Enter password again",
                      obscureText: controller.hidePassword.value,
                      validatorCallback: (val) {
                        if (val == null || val.isEmpty) {
                          return "Password is required";
                        }
                        if (val != controller.registerPasswordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                      suffixIcon: IconButton(icon: Icon(controller.hidePassword.value ? Icons.visibility_off : Icons.visibility), onPressed: controller.togglePasswordVisibility),
                    );
                  }),

                  const SizedBox(height: 20),

                  /// SUBMIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: Obx(() {
                      return ElevatedButton(
                        onPressed: controller.isLoading.value ? null : controller.register,
                        child: controller.isLoading.value ? const CircularProgressIndicator(color: Colors.black) : const Text("Submit"),
                      );
                    }),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: "Already have an account ? ",
                        children: [
                          TextSpan(
                            text: "Login",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed(RouteNames.login),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
