import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:ngirit_app/providers/budget_provider.dart';
import 'package:ngirit_app/providers/common_provider.dart';
import 'package:ngirit_app/providers/expense_provider.dart';
import 'package:ngirit_app/providers/summaries_provider.dart';
import 'package:ngirit_app/widgets/common/generic/ui_feedback.dart';
import '../../services/biometric_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometric() async {
    final provider = context.read<AuthProvider>();
    final available = await BiometricService.isAvailable();
    final hasCreds = await provider.hasSavedCredentials();
    if (!hasCreds && mounted) {
      UiFeedback.show(
        context,
        message: "Please login first to enable biometric auth",
        type: FeedbackType.info,
      );
    }
    if (mounted) setState(() => _biometricAvailable = available && hasCreds);
  }

  Future<void> _loginWithBiometric() async {
    final authenticated = await BiometricService.authenticate();
    if (!authenticated) return;
    if (!mounted) return;

    final provider = context.read<AuthProvider>();
    // if (provider.userId == null) return;
    final savedIdentity = await provider.getSavedIdentity();
    final savedPassword = await provider.getSavedPassword();

    if (savedIdentity == null || savedPassword == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please login first to enable biometric auth"),
        ),
      );
      return;
    }

    provider.login(savedIdentity, savedPassword);
  }

  void _navigateIfLoggedIn(AuthProvider authProvider) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BudgetProvider>().init(authProvider.userId);
      context.read<ExpenseProvider>().init(authProvider.userId);
      context.read<SummariesProvider>().init(authProvider.userId);
      context.read<CommonProvider>().exchangeRate = 1.0;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.home,
        arguments: {'userId': authProvider.userId},
      );
    });
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "",
          style: TextStyle(fontSize: 28, color: appTheme.secondary),
        ),
        backgroundColor: appTheme.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            //Auto Nagivate listener
            if (authProvider.userId != null) {
              _navigateIfLoggedIn(authProvider);
            }

            // show error snackbar
            if (authProvider.error != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(authProvider.error!)));
              });
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.only(top: 64),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/app_icon.png',
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                  TextField(
                    controller: idController,
                    decoration: const InputDecoration(
                      labelText: "Email/Username",
                    ),
                    enabled: !authProvider.isLoading,
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                    enabled: !authProvider.isLoading,
                  ),
                  const SizedBox(height: 20),

                  if (authProvider.isLoading)
                    const CircularProgressIndicator()
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // if (!isKeyboardOpen)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appTheme.tertiary,
                          ),
                          onPressed: () {
                            // final commonProvider = context
                            //     .read<CommonProvider>();
                            // await commonProvider.checkHealth();
                            //
                            // if (!commonProvider.serverReachable) {
                            //   return;
                            // }
                            // if (!context.mounted) return;
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.register,
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.person_add),
                              SizedBox(width: 5),
                              Text(
                                "Registers",
                                style: TextStyle(color: appTheme.primary),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        // if (!isKeyboardOpen)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appTheme.tertiary,
                          ),
                          onPressed: () async {
                            final identity = idController.text.trim();
                            final password = passwordController.text.trim();

                            if (identity.isEmpty || password.isEmpty) {
                              UiFeedback.show(
                                context,
                                message: "Email and Password Required",
                                type: FeedbackType.info,
                              );
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   const SnackBar(
                              //     content: Text("Email and Password Required"),
                              //   ),
                              // );
                              return;
                            }

                            await authProvider.login(identity, password);
                            if (!mounted) return;
                            if (authProvider.userId == null) {
                              if (!context.mounted) return;
                              // showError("Invalid Cred");
                              authProvider.clearCredentials();
                              _biometricAvailable = false;
                              UiFeedback.show(
                                context,
                                message: "Invalid Username/Password",
                                type: FeedbackType.error,
                              );
                            }
                          },
                          child: Row(
                            children: [
                              Icon(Icons.login),
                              SizedBox(width: 5),
                              Text(
                                "Login",
                                style: TextStyle(color: appTheme.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                  if (_biometricAvailable) ...[
                    const SizedBox(height: 16),
                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.fingerprint),
                      tooltip: 'Login with biometrics',
                      onPressed: _loginWithBiometric,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
