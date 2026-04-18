import 'package:flutter/material.dart';
import 'package:ngirit_app/providers/common_provider.dart';
import '../models/expenses.dart';
import '../services/expense_service.dart';

class ExpenseProvider extends ChangeNotifier {
  CommonProvider commonProvider;
  ExpenseProvider(this.commonProvider);
  // State management
  late String userId;
  void init(uid) {
    userId = uid;
    fetchExpenses(uid, DateTime.now().toIso8601String().split('T').first);
    notifyListeners();
  }

  DateTime _selectedDate = DateTime.now();
  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // get state
  DateTime get selectedDate => _selectedDate;
  bool get isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  String get expenseListTitle => isToday ? "Today Expenses" : "Expenses List";

  double get totalAmount => expenses.fold(0, (sum, item) => sum + item.amount);

  // Call api services
  final ExpenseService _service = ExpenseService();

  // Data state
  List<ExpenseResponse> expenses = [];
  ExpenseResponse? newExpense;
  ExpenseResponse? editExpense;
  bool isLoading = false;

  // internal logic
  void setDateAndFetch(String userId, DateTime date) {
    _selectedDate = date;
    final formattedDate = date.toIso8601String().split('T').first;
    fetchExpenses(userId, formattedDate);
  }

  Future<void> deleteExpense(String expenseId) async {
    // start
    isLoading = true;
    notifyListeners();

    try {
      await _service.deleteExpense(userId: userId, expenseId: expenseId);

      // fetch expense
      final date = DateTime.now();
      final formattedDate = date.toIso8601String().split('T').first;
      await fetchExpenses(
        userId,
        formattedDate,
      ); // notify is loading false handle internally
      // debugPrint('Fetch Done');
    } catch (e) {
      commonProvider.setServerReachable(false);
      debugPrint(e.toString());
      isLoading = false;
      notifyListeners();
    }
  }

  // api call
  Future<void> updateExpense(
    String expenseId,
    String? name,
    String? category,
    int? amount,
  ) async {
    // update start
    isLoading = true;
    notifyListeners();

    try {
      await _service.updateExpense(
        userId: userId,
        expenseId: expenseId,
        name: name,
        category: category,
        amount: amount,
      );

      final date = DateTime.now();
      final formattedDate = date.toIso8601String().split('T').first;
      await fetchExpenses(userId, formattedDate);
    } catch (e) {
      commonProvider.setServerReachable(false);
      debugPrint(e.toString());
      //update done
      isLoading = false; // notify when fetchExpenses didnt run
      notifyListeners();
    }
  }

  Future<void> fetchExpenses(String userId, String date) async {
    isLoading = true;
    notifyListeners();

    try {
      expenses = await _service.getExpenseByDate(userId: userId, date: date);
    } catch (e) {
      commonProvider.setServerReachable(false);
      throw Exception(e.toString());
      // debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getExpenseById(String userId, String expenseId) async {
    isLoading = true;
    notifyListeners();

    try {
      editExpense = await _service.getExpenseById(
        userId: userId,
        expenseId: expenseId,
      );
    } catch (e) {
      commonProvider.setServerReachable(false);
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
      commonProvider.setServerReachable(false);
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
