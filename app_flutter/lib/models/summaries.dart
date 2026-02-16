// lib/models/summary.dart

class Summaries {
  final Map<String, double> categories;
  final String dateString;
  final double totalExpenses;
  final String type;

  Summaries({
    required this.categories,
    required this.dateString,
    required this.totalExpenses,
    required this.type,
  });

  factory Summaries.fromJson(Map<String, dynamic> json) {
    return Summaries(
      categories: (json['categoryBreakdown'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      dateString: json['monthYear'] ?? json['date'] as String,
      totalExpenses: json['totalExpenses'] as double,
      type: json['type'] as String,
    );
  }
}
