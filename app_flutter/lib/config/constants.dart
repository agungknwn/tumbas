import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Base URL - change based on environment
  static final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8081';
  // static const String baseUrl = 'http://10.1.20.157:8081';

  // For Android Emulator use:
  // static const String baseUrl = 'http://10.0.2.2:8080';

  // For real device/production use:
  // static const String baseUrl = 'https://yourdomain.com';

  // Auth endpoints - match your Go routes
  // Get endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static String expenseByDate({required String userId, required String date}) =>
      '/users/$userId/expenses/by-date/$date';

  // Expenses endpoints
  // Post Endpoints
  static String addExpense({required String userId}) =>
      '/users/$userId/expenses';

  // Delete endpoints
  static String deleteExpense({
    required String userId,
    required String expenseId,
  }) => '/users/$userId/expenses/$expenseId';

  // Budget endpoints
  // Generic endpoints
  static String userBudget({
    required String userId,
    required String budgetId,
  }) => '/users/$userId/budgets/$budgetId';
  // Post endpoints
  static String createNewBudget({required String userId}) =>
      '/users/$userId/budgets';

  // Summaries endpoints
  static String getSummaries({
    required String userId,
    required String type,
    required String dateString,
  }) => '/users/$userId/summaries/$type/$dateString';

  // Helper to get full URL
  static String getUrl(String endpoint) => '$baseUrl$endpoint';
}
