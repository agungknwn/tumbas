import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ngirit_app/widgets/navigation_bar.dart';
import 'register_screen.dart';

const String api = "http://192.168.225.58:8080"; // or IP if phone

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and Password required")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("$api/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userId = data["userId"];

        // Optional: store userId locally
        // await SecureStorage.saveUserId(userId);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ScreenNavigation(userId: userId)),
        );
      } else {
        // print("STATUS: ${response.statusCode}");
        // print("BODY: ${response.body}");
        // print("USERNAME: ${email}");
        // print("PASS: ${password}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid Username or Password")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login", style: TextStyle(fontSize: 28)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text("Registers"),
                ),
                SizedBox(width: 10),
                ElevatedButton(onPressed: login, child: const Text("Login")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
