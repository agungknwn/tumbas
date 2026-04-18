// lib/models/budget.dart

class ExpenseResponse {
  final double amount;
  final String name;
  final String category;
  final String date;
  final String monthYear;
  final String expenseId;

  ExpenseResponse({
    required this.name,
    required this.monthYear,
    required this.amount,
    required this.category,
    required this.date,
    required this.expenseId,
  });

  factory ExpenseResponse.fromJson(Map<String, dynamic> json) {
    return ExpenseResponse(
      name: json['name'] as String,
      monthYear: json['monthYear'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      date: json['date'] as String,
      expenseId: json['expenseId'] as String,
    );
  }
}
