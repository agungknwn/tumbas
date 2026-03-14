import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ngirit_app/providers/expense_provider.dart';
import '../../widgets/common/datepicker.dart';
import '../../widgets/common/expense/expense_list.dart';
import '../../widgets/common/expense/expense_list_header.dart';
import '../../widgets/common/expense/expense_screen_header.dart';
import '../../widgets/common/expense/expense_summary.dart';

class ExpensesScreen extends StatelessWidget {
  // final Function(String, String, String)? onAddExpense;
  final String userId;
  const ExpensesScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    // if (provider.isLoading) {
    //   return CircularProgressIndicator();
    // }
    return Scaffold(
      body: Column(
        children: [
          // Blue header section
          ScreenHeader(),
          // Date picker aligned left
          Align(
            alignment: Alignment.centerLeft,
            child: DatePickerWidget(
              onDateSelected: (date) =>
                  context.read<ExpenseProvider>().setDateAndFetch(userId, date),
            ),
          ),

          // if (provider.isLoading) Center(child: CircularProgressIndicator()),

          // White content section with overlap
          Expanded(
            child: Stack(
              children: [
                if (provider.isLoading)
                  Center(child: CircularProgressIndicator()),
                // Total expenses card (overlapping)
                SummaryCard(total: provider.totalAmount),
                ExpenseListHeader(title: provider.expenseListTitle),
                // Scrollable expense list
                ExpenseList(
                  expenses: provider.expenses,
                  isToday: provider.isToday,
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}

// builder: (context, expenseProvider, child) {
//                 if (expenseProvider.isLoading) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//
//                 return Stack(
//                   children: [
//                     // Total expenses card (overlapping)
//                     SummaryCard(total: expenseProvider.totalAmount),
//                     ExpenseListHeader(title: expenseProvider.expenseListTitle),
//                     // Scrollable expense list
//                     ExpenseList(
//                       // onEditButtonPressed: (expenseId) => context
//                       //     .read<ExpenseProvider>()
//                       //     .getExpenseById(userId, expenseId),
//                       expenses: expenseProvider.expenses,
//                       isToday: expenseProvider.isToday,
//                     ),
//                   ],
//                 );
//               },
// Consumer<ExpenseProvider>(
//               builder: (context, expenseProvider, child) {
//                 if (expenseProvider.isLoading) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//
//                 return Stack(
//                   children: [
//                     // Total expenses card (overlapping)
//                     SummaryCard(total: expenseProvider.totalAmount),
//                     ExpenseListHeader(title: expenseProvider.expenseListTitle),
//                     // Scrollable expense list
//                     ExpenseList(
//                       // onEditButtonPressed: (expenseId) => context
//                       //     .read<ExpenseProvider>()
//                       //     .getExpenseById(userId, expenseId),
//                       expenses: expenseProvider.expenses,
//                       isToday: expenseProvider.isToday,
//                     ),
//                   ],
//                 );
//               },
//             ),
//
