import '../config/constants.dart';
import '../models/expenses.dart';
import 'api_service.dart';

class ExpenseService {
  final ApiService _api = ApiService();

  // Register - calls POST /auth/register
  Future<ExpenseResponse> addExpense({
    required String userId,
    required int amount,
    required String category,
    required String name,
    required String date,
    required String monthYear,
  }) async {
    final response = await _api.post(
      ApiConstants.addExpense(userId: userId), // This is '/auth/register'
      {
        'amount': amount,
        'category': category,
        'name': name,
        'date': date,
        'monthYear': monthYear,
      },
    );

    // Assuming your Go backend returns:
    // {
    //   "success": true,
    //   "message": "User created",
    //   "user": {...}
    // }

    if (response['data'] != null) {
      return ExpenseResponse.fromJson(response['data']);
    } else {
      throw Exception('add expense failed');
    }
  }

  Future<List<ExpenseResponse>> getExpenseByDate({
    required String userId,
    required String date,
  }) async {
    final response = await _api.get(
      ApiConstants.expenseByDate(userId: userId, date: date),
    );

    if (response is! List) {
      throw Exception('get expense by date failed');
    }

    return response
        .map<ExpenseResponse>((json) => ExpenseResponse.fromJson(json))
        .toList();
  }
}
