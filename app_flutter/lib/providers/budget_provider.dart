import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import '../services/budget_service.dart';

class BudgetProvider extends ChangeNotifier {
  late String userId;

  DateTime selectedDate = DateTime.now();

  final DateFormat _formatter = DateFormat('yyyy-MM');

  String get monthYear => _formatter.format(selectedDate);
  String get budgetId => "budget_$monthYear";
  // define services
  final BudgetService _service = BudgetService();

  Budget? userBudget;
  bool isLoading = false;

  void init(uid) {
    userId = uid;
    _initMonthlyBudget();
  }

  // Call services
  Future<void> _initMonthlyBudget() async {
    debugPrint(">>> _initMonthlyBudget START");
    isLoading = true;
    notifyListeners();

    try {
      // check current month budget
      final currentBudget = await _service.getBudget(
        userId: userId,
        budgetId: budgetId,
      );

      debugPrint("Budget status $currentBudget");
      if (currentBudget != null) {
        userBudget = currentBudget;
        return;
      }

      // copy prev month budget
      final prevDate = DateTime(selectedDate.year, selectedDate.month - 1);
      final prevBudgetId = 'budget_${_formatter.format(prevDate)}';

      final prevBudget = await _service.getBudget(
        userId: userId,
        budgetId: prevBudgetId,
      );

      if (prevBudget != null) {
        await _service.createBudget(
          userId: userId,
          amount: prevBudget.amount,
          currency: prevBudget.currency,
          monthYear: monthYear,
        );

        userBudget = Budget(
          monthYear: monthYear,
          amount: prevBudget.amount,
          currency: prevBudget.currency,
        );

        return;
      }

      // new user fallback
      await _service.createBudget(
        userId: userId,
        amount: 0,
        currency: 'USD',
        monthYear: monthYear,
      );
      userBudget = Budget(monthYear: monthYear, amount: 0, currency: 'USD');
    } catch (e, st) {
      debugPrint("_initMonthlyBudget ERROR: $e");
      debugPrintStack(stackTrace: st);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBudget() async {
    isLoading = true;
    notifyListeners();

    try {
      userBudget = await _service.getBudget(userId: userId, budgetId: budgetId);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBudget(double amount, String currency) async {
    isLoading = true;

    userBudget = Budget(
      monthYear: monthYear,
      amount: amount,
      currency: currency,
    );

    notifyListeners();

    try {
      await _service.updateBudget(
        userId: userId,
        budgetId: budgetId,
        amount: amount,
        currency: currency,
        monthYear: monthYear,
      );
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
