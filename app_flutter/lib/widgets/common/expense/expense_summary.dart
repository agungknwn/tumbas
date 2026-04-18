import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ngirit_app/providers/common_provider.dart';
import 'package:provider/provider.dart';

class SummaryCard extends StatelessWidget {
  final double total;
  final String currency;

  const SummaryCard({super.key, required this.total, required this.currency});

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context).colorScheme;
    final exchangeRate = context.watch<CommonProvider>().exchangeRate;
    var currencyFormat = NumberFormat.simpleCurrency(name: currency);
    return Positioned(
      top: 16,
      left: 24,
      right: 24,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: appTheme.tertiary, width: 6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Daily Expenses',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              // 'Rp. ${total.toStringAsFixed(0)}',
              currencyFormat.format(total * exchangeRate),
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
