import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:thread_clone/controllers/auth_controller.dart';
import 'package:thread_clone/routes/route_names.dart';
import 'package:thread_clone/widgets/auth_text_field_widget.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final AuthController controller = Get.put(AuthController());  bool hidePassword = true;

  /// 🔑 Register-only FormKey
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() {
    setState(() {
      hidePassword = !hidePassword;
    });
  }

  void register() {
    if (formKey.currentState!.validate()) {
      if (!controller.registerLoading.value) {
        controller.register(nameController.text.trim(), emailController.text, passwordController.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Image.asset("assets/images/logo.png", width: 60, height: 60)),

                  const SizedBox(height: 20),

                  const Text("Register", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  const Text("Welcome to the threads world"),

                  const SizedBox(height: 20),

                  /// NAME
                  AuthTextFieldWidget(controller: nameController, labelText: "Name", hintText: "Enter name", validatorCallback: ValidationBuilder().required().minLength(2).maxLength(50).build()),

                  const SizedBox(height: 20),

                  /// EMAIL
                  AuthTextFieldWidget(controller: emailController, labelText: "Email", hintText: "Enter email", validatorCallback: ValidationBuilder().required().email().build()),

                  const SizedBox(height: 20),

                  /// PASSWORD
                  AuthTextFieldWidget(
                      controller: passwordController,
                      labelText: "Password",
                      hintText: "Enter password",
                      obscureText: hidePassword,
                      validatorCallback: ValidationBuilder(requiredMessage: "Password is required").required().minLength(6).maxLength(20).build(),
                      suffixIcon: IconButton(icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility), onPressed: togglePasswordVisibility),
                    ),

                  const SizedBox(height: 20),

                  /// CONFIRM PASSWORD
                   AuthTextFieldWidget(
                      controller: confirmPasswordController,
                      labelText: "Confirm Password",
                      hintText: "Enter password again",
                      obscureText: hidePassword,
                      validatorCallback: (val) {
                        if (val == null || val.isEmpty) {
                          return "Password is required";
                        }
                        if (val != passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                      suffixIcon: IconButton(icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility), onPressed: togglePasswordVisibility),
                    ),

                  const SizedBox(height: 20),

                  /// SUBMIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: Obx(() {
                      return ElevatedButton(
                        onPressed: () => controller.registerLoading.value ? null : register(),
                        child: controller.registerLoading.value ? const CircularProgressIndicator(color: Colors.black) : const Text("Submit"),
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
