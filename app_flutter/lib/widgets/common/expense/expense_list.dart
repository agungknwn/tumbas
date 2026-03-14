import 'package:flutter/material.dart';
import '../../../models/expenses.dart';
import '../../../widgets/common/expense/expense_card.dart';

class ExpenseList extends StatelessWidget {
  final bool isToday;
  final List<ExpenseResponse> expenses;
  // final Future<void> Function(String expenseId) onEditButtonPressed;

  const ExpenseList({
    super.key,
    required this.expenses,
    required this.isToday,
    // required this.onEditButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 200),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 24),
        itemCount: expenses.length,
        separatorBuilder: (_, __) => SizedBox(height: 12),
        itemBuilder: (_, index) {
          final item = expenses[index];
          return ExpenseCard(
            expenseId: item.expenseId,
            title: item.name,
            category: item.category,
            price: 'Rp. ${item.amount.toStringAsFixed(0)}',
            isToday: isToday,
            // (expenseId) => onEditButtonPressed(item.expenseId),
            // onEditButtonPressed: onEditButtonPressed,
          );
        },
      ),
    );
  }

  // Widget ExpenseCard(
  //   String title,
  //   String category,
  //   String price,
  //   bool isToday,
  //   String expenseId,
  //   Future<void> Function(String expenseId) onEditButtonPressed,
  // ) {
  //   return Container(
  //     padding: EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 8,
  //           offset: Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               title,
  //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  //             ),
  //             SizedBox(height: 4),
  //             Text(
  //               category,
  //               style: TextStyle(fontSize: 14, color: Colors.grey),
  //             ),
  //           ],
  //         ),
  //         Row(
  //           children: [
  //             Text(
  //               price,
  //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  //             ),
  //             SizedBox(width: 5),
  //             if (isToday)
  //               EditButton(
  //                 expenseId: expenseId,
  //                 onEditButtonPressed: onEditButtonPressed,
  //               ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
