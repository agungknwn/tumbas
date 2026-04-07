import 'package:flutter/material.dart';
import 'package:ngirit_app/screens/feature/expenses_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/navigation_screen.dart';
import '../widgets/common/exit_wrapper.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String expenses = '/expenses';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case home:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ExitWrapper(
            child: NavigationScreen(
              userId: args?['userId'],
              onAddExpense: (title, amount, category) {
                print("Title:$title, Amount:$amount, Cat:$category");
              },
            ),
          ),
        );
      case expenses:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ExpensesScreen(userId: args?['userId']),
        );
      default:
        return MaterialPageRoute(builder: (_) => LoginScreen());
    }
  }
}
