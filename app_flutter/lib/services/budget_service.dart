import 'package:flutter/cupertino.dart';

import '../config/constants.dart';
import '../models/budget.dart';
import 'api_service.dart';

class BudgetService {
  final ApiService _api = ApiService();

  // Register get budget service
  Future<Budget?> getBudget({
    required String userId,
    required String budgetId,
  }) async {
    debugPrint(">>> getBudget START $budgetId");
    final response = await _api.get(
      ApiConstants.userBudget(userId: userId, budgetId: budgetId),
    );

    debugPrint(">>> getBudget RESPONSE $response");
    if (response != null) {
      return Budget.fromJson(response);
    } else {
      return null;
      // throw Exception('Get budget failed');
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
      {'amount': amount, 'currency': currency, 'monthYear': monthYear},
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
    required double exchangeRate,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    final response = await _api
        .put(ApiConstants.userBudget(userId: userId, budgetId: budgetId), {
          "amount": amount,
          "currency": currency,
          "monthYear": monthYear,
          "exchangeRate": exchangeRate,
          "fromCurrency": fromCurrency,
          "toCurrency": toCurrency,
        });

    if (response['message'] == "Budget Updated") {
      return response['data'];
    } else {
      throw Exception('update budget failed');
    }
  }
}
