import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:thread_clone/controllers/auth_controller.dart';
import 'package:thread_clone/routes/route_names.dart';
import 'package:thread_clone/widgets/auth_text_field_widget.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController controller = Get.find<AuthController>();
   bool hidePassword = true;

  /// 🔑 Login-only FormKey
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    if (formKey.currentState!.validate()) {
      if (!controller.loginLoading.value) {
        controller.login(emailController.text, passwordController.text);
      }
    }
  }

  void togglePasswordVisibility() {
    setState(() {
      hidePassword = !hidePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Image.asset("assets/images/logo.png", width: 60, height: 60)),

                  const SizedBox(height: 20),

                  const Text("Login", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  const Text("Welcome back"),

                  const SizedBox(height: 20),

                  /// EMAIL
                  AuthTextFieldWidget(controller: emailController, labelText: "Email", hintText: "Email", validatorCallback: ValidationBuilder().required().email().build()),

                  const SizedBox(height: 20),

                  /// PASSWORD
                  AuthTextFieldWidget(
                      controller: passwordController,
                      labelText: "Password",
                      hintText: "Password",
                      obscureText: hidePassword,
                      validatorCallback: ValidationBuilder().required().minLength(6).maxLength(20).build(),
                      suffixIcon: IconButton(icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility), onPressed: togglePasswordVisibility),
                    ),

                  const SizedBox(height: 20),

                  /// SUBMIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: Obx(() {
                      return ElevatedButton(
                        onPressed: () => controller.loginLoading.value ? null : login(),
                        child: controller.loginLoading.value ? const CircularProgressIndicator(color: Colors.black) : const Text("Submit"),
                      );
                    }),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: "Don't have an account ? ",
                        children: [
                          TextSpan(
                            text: "Register",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed(RouteNames.register),
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
