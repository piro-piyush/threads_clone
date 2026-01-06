import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:thread_clone/routes/route_names.dart';
import 'package:thread_clone/widgets/auth_text_field_widget.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late GlobalKey<FormState> _formKey;
  bool hidePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void togglePasswordVisibility() {
    setState(() {
      hidePassword = !hidePassword;
    });
  }

  void submit() {
    if (!_formKey.currentState!.validate()) return;
    Get.toNamed(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset("assets/images/logo.png", width: 60, height: 60),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Login", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                        const Text("Welcome back"),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  AuthTextFieldWidget(hintText: "Email", labelText: "Email", controller: _emailController, validatorCallback: ValidationBuilder().required().email().build()),
                  SizedBox(height: 20),
                  AuthTextFieldWidget(
                    hintText: "Password",
                    labelText: "Password",
                    controller: _passwordController,
                    obscureText: hidePassword,
                    validatorCallback: ValidationBuilder().required().minLength(6).maxLength(20).build(),
                    suffixIcon: IconButton(onPressed: () => togglePasswordVisibility(), icon: Icon(hidePassword ? Icons.visibility_off : Icons.remove_red_eye)),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(onPressed: submit, child: Text("Submit")),
                  ),
                  SizedBox(height: 20),
                  Text.rich(
                    TextSpan(
                      text: "Don't have an account ? ",
                      children: [
                        TextSpan(
                          text: "Register",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed(RouteNames.register),
                        ),
                      ],
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
