import 'package:flutter/material.dart';
import 'package:ngirit_app/providers/auth_provider.dart';
import 'package:ngirit_app/providers/common_provider.dart';
import 'package:ngirit_app/widgets/common/generic/ui_feedback.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';

const String api = "http://192.168.225.58:8080"; // or IP if phone

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController =
      TextEditingController();

  Future<void> _onRegister() async {
    //check healh
    final commonProvider = context.read<CommonProvider>();
    await commonProvider.checkHealth();

    if (!commonProvider.serverReachable) {
      return;
    }

    if (!mounted) return;

    // parse controller
    final fullname = fullnameController.text.trim();
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final passwordConfirm = passwordConfirmController.text.trim();

    if (email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        passwordConfirm.isEmpty) {
      UiFeedback.show(
        context,
        message: "All fields are required",
        type: FeedbackType.info,
      );
      return;
    }

    if (password != passwordConfirm) {
      UiFeedback.show(
        context,
        message: "Password do not match",
        type: FeedbackType.error,
      );
      return;
    }

    final provider = context.read<AuthProvider>();
    try {
      await provider.register(email, username, fullname, password);

      if (!mounted) return;

      if (provider.registerStatus == true) {
        provider.registerStatus = false;
        UiFeedback.show(
          context,
          message: "Registration success",
          type: FeedbackType.success,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      } else {
        UiFeedback.show(
          context,
          message: "Registration failed",
          type: FeedbackType.error,
        );
      }
    } catch (e) {
      UiFeedback.show(
        context,
        message: "Registration failed: ${e.toString()}",
        type: FeedbackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();
    final appTheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Register Form"),

            InputField(
              fieldName: "Full Name: ",
              controller: fullnameController,
              obscured: false,
            ),
            InputField(
              fieldName: "Username: ",
              controller: usernameController,
              obscured: false,
            ),
            InputField(
              fieldName: "Email: ",
              controller: emailController,
              obscured: false,
            ),
            InputField(
              fieldName: "Password: ",
              controller: passwordController,
              obscured: true,
            ),
            InputField(
              fieldName: "Password Confirmation: ",
              controller: passwordConfirmController,
              obscured: true,
            ),
            SizedBox(height: 20),

            if (provider.isLoading)
              const CircularProgressIndicator()
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    ),
                    child: Text("Back to Login Page"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appTheme.tertiary,
                    ),
                    onPressed: _onRegister,
                    child: Text(
                      "Register",
                      style: TextStyle(color: appTheme.primary),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.fieldName,
    required this.controller,
    required this.obscured,
  });

  final String fieldName;
  final TextEditingController controller;
  final bool obscured;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(fieldName),
        SizedBox(width: 12),
        Expanded(
          child: TextField(controller: controller, obscureText: obscured),
        ),
      ],
    );
  }
}
