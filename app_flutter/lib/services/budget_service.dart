import '../config/constants.dart';
import '../models/budget.dart';
import 'api_service.dart';

class BudgetService {
  final ApiService _api = ApiService();

  // Register get budget service
  Future<Budget> getBudget({
    required String userId,
    required String budgetId,
  }) async {
    final response = await _api.get(
      ApiConstants.userBudget(userId: userId, budgetId: budgetId),
    );

    if (response != null) {
      return Budget.fromJson(response);
    } else {
      throw Exception('Get budget failed');
    }
  }

  // Register post budget service
  Future<dynamic> createBudget({
    required String userId,
    required double amount,
    required String currency,
    required String monthYear,
  }) async {
    final response = await _api.post(
      ApiConstants.createNewBudget(userId: userId),
      {'amount': amount, 'cucurrency': currency, 'monthYear': monthYear},
    );

    if (response['budgetId'] != null) {
      return response['budgetId'];
    } else {
      throw Exception('create new budget failed');
    }
  }

  // Register patch service
  Future<dynamic> updateBudget({
    required String userId,
    required String budgetId,
    required double amount,
    required String currency,
    required String monthYear,
  }) async {
    final response = await _api.put(
      ApiConstants.userBudget(userId: userId, budgetId: budgetId),
      {"amount": amount, "currency": currency, "monthYear": monthYear},
    );

    if (response['message'] == "Budget Updated") {
      return response['data'];
    } else {
      throw Exception('update budget failed');
    }
  }
}
