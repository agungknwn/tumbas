import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/summaries.dart';
import '../services/summaries_service.dart';

class SummariesProvider extends ChangeNotifier {
  late String userId;

  DateTime selectedDate = DateTime.now();
  final DateFormat _formatter = DateFormat('yyyy-MM');

  String get monthYear => _formatter.format(selectedDate);

  // define service
  final SummariesService _service = SummariesService();

  // state
  Summaries? monthlySummaries;
  bool isLoading = false;

  // init func
  void init(uid) {
    userId = uid;
  }

  // Call service
  Future<void> getMonthlySummaries() async {
    // if (monthlySummaries != null) return;
    isLoading = true;
    notifyListeners();

    try {
      monthlySummaries = await _service.getSummaries(
        userId: userId,
        type: 'monthly',
        dateString: monthYear,
      );
    } catch (e) {
      Exception(e.toString());
      print("getMonthlySummaries error: $e");
    } finally {
      print("Summaries Provider: $monthlySummaries");
      isLoading = false;
      notifyListeners();
    }
  }
}
