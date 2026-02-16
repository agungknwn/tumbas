// lib/models/budget.dart

class Budget {
  final String monthYear;
  final double amount;
  final String currency;

  Budget({
    required this.monthYear,
    required this.amount,
    required this.currency,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      monthYear: json['monthYear'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
    );
  }
}
