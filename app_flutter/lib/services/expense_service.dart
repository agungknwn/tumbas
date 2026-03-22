import '../config/constants.dart';
import '../models/expenses.dart';
import 'api_service.dart';

class ExpenseService {
  final ApiService _api = ApiService();

  // [GIN-debug] PATCH  /users/:userId/expenses/:expenseId --> github.com/agungknwn/ngirit_backend/internal/handlers.PatchExpense (4 handlers)
  Future<dynamic> deleteExpense({
    required String userId,
    required String expenseId,
  }) async {
    final response = await _api.delete(
      ApiConstants.deleteExpense(userId: userId, expenseId: expenseId),
    );

    if (response["error"] != null) {
      throw Exception(response["error"]);
    }
  }

  Future<dynamic> updateExpense({
    required String userId,
    required String expenseId,
    int? amount,
    String? category,
    String? name,
  }) async {
    final response = await _api.patch(
      ApiConstants.updateExpense(userId: userId, expenseId: expenseId),
      {
        if (amount != null) 'amount': amount,
        if (category != null) 'category': category,
        if (name != null) 'name': name,
      },
    );

    if (response["message"] != null && response["message"] != "success") {
      throw Exception(response["error"]);
    }
  }

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

  Future<ExpenseResponse> getExpenseById({
    required String userId,
    required String expenseId,
  }) async {
    final response = await _api.get(
      ApiConstants.expenseById(userId: userId, expenseId: expenseId),
    );

    if (response == null) {
      throw Exception('get expense by ID failed:');
    }

    return ExpenseResponse.fromJson(response);
  }
}
