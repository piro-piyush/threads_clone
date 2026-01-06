import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:thread_clone/routes/route_names.dart';
import 'package:thread_clone/widgets/auth_text_field_widget.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _nameController;
  late GlobalKey<FormState> _formKey;
  bool hidePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _nameController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
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
                        const Text("Register", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                        const Text("Welcome to the threads world"),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  AuthTextFieldWidget(hintText: "Enter name", labelText: "Name", validatorCallback: ValidationBuilder().required().minLength(2).maxLength(50).build(), controller: _nameController),
                  SizedBox(height: 20),
                  AuthTextFieldWidget(hintText: "Enter email", labelText: "Email", validatorCallback: ValidationBuilder().required().email().build(), controller: _emailController),
                  SizedBox(height: 20),
                  AuthTextFieldWidget(
                    hintText: "Enter password",
                    labelText: "Password",
                    controller: _passwordController,
                    obscureText: hidePassword,
                    validatorCallback: ValidationBuilder().required().minLength(6).maxLength(20).build(),
                    suffixIcon: IconButton(onPressed: () => togglePasswordVisibility(), icon: Icon(hidePassword ? Icons.visibility_off : Icons.remove_red_eye)),
                  ),
                  SizedBox(height: 20),
                  AuthTextFieldWidget(
                    hintText: "Enter password again",
                    labelText: "Confirm Password",
                    controller: _confirmPasswordController,
                    obscureText: hidePassword,
                    validatorCallback: (val) {
                      if (val != _passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
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
                      text: "Already have an account ? ",
                      children: [
                        TextSpan(
                          text: "Login",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed(RouteNames.login),
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
