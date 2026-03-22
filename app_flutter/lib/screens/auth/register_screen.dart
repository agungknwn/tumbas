import 'package:flutter/material.dart';
import 'package:ngirit_app/providers/auth_provider.dart';
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
    final fullname = fullnameController.text.trim();
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final passwordConfirm = passwordConfirmController.text.trim();

    if (email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        passwordConfirm.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All fields are required")));
      return;
    }

    if (password != passwordConfirm) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    final provider = context.read<AuthProvider>();
    try {
      await provider.register(email, username, fullname, password);

      if (!mounted) return;

      if (provider.registerStatus == true) {
        provider.registerStatus = false;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("register failed")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Register failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
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
                    onPressed: _onRegister,
                    child: Text("Register"),
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
