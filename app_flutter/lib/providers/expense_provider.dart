import 'package:flutter/material.dart';
import '../models/expenses.dart';
import '../services/expense_service.dart';

class ExpenseProvider extends ChangeNotifier {
  // State management
  DateTime selectedDate = DateTime.now();
  void setDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  // Call services
  final ExpenseService _service = ExpenseService();

  List<ExpenseResponse> expenses = [];
  ExpenseResponse? newExpense;
  bool isLoading = false;

  Future<void> fetchExpenses(String userId, String date) async {
    isLoading = true;
    notifyListeners();

    try {
      expenses = await _service.getExpenseByDate(userId: userId, date: date);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNewExpense(
    String userId,
    int amount,
    String category,
    String? name,
    String date,
    String monthYear,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      newExpense = await _service.addExpense(
        userId: userId,
        amount: amount,
        category: category,
        name: name ?? "No Description",
        date: date,
        monthYear: monthYear,
      );

      expenses.add(newExpense!); // optional optimistic update
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
