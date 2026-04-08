import 'package:flutter/material.dart';
import 'package:ngirit_app/providers/expense_provider.dart';
import 'package:provider/provider.dart';
import '../popup/expense_form.dart';

class ExpenseCard extends StatelessWidget {
  final String expenseId;
  final String title;
  final String category;
  final String price;
  final bool isToday;

  // callback func
  // final Function? onEditButtonPressed;
  const ExpenseCard({
    super.key,
    required this.expenseId,
    required this.title,
    required this.category,
    required this.price,
    required this.isToday,
    // this.onEditButtonPressed,
  });
  @override
  Widget build(BuildContext context) {
    final provider = context.read<ExpenseProvider>();
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: categoryColors[category] ?? Colors.black,
            width: 3,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              // category name
              Row(
                children: [
                  Icon(
                    getCategoryIcon(category),
                    size: 16,
                    color: categoryColors[category],
                  ),
                  SizedBox(width: 5),
                  Text(
                    category,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Text(
                price,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 5),
              if (isToday)
                EditButton(
                  expenseId: expenseId,
                  onClick: provider.getExpenseById,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class EditButton extends StatelessWidget {
  final String expenseId;
  final Function? onClick;
  const EditButton({super.key, required this.expenseId, required this.onClick});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ExpenseProvider>();
    return Builder(
      builder: (context) => IconButton(
        icon: Icon(Icons.edit, size: 20, color: Colors.green),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ExpenseForm(
                    editMode: true,
                    submitText: "Edit Expense",
                    deleteText: "Delete",
                    expenseId: expenseId,
                    userId: provider.userId,
                    onOpen: (expenseId) => onClick!(provider.userId, expenseId),
                    onSubmit:
                        (
                          String id,
                          String title,
                          int amount,
                          String category,
                        ) async {
                          final expenseProvider = context
                              .read<ExpenseProvider>();
                          await expenseProvider.updateExpense(
                            id,
                            title,
                            category,
                            amount,
                          );
                          if (context.mounted) {
                            Navigator.pop(context, true);
                          }
                        },
                    onDelete: (String id) async {
                      final expenseProvider = context.read<ExpenseProvider>();
                      await expenseProvider.deleteExpense(id);
                      if (context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// helper func
IconData getCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return Icons.restaurant;
    case 'transport':
      return Icons.directions_car;
    case 'shopping':
      return Icons.shopping_bag;
    case 'entertainment':
      return Icons.movie;
    case 'bills':
      return Icons.receipt_long;
    case 'health':
      return Icons.favorite;
    case 'education':
      return Icons.school;
    case 'other':
    default:
      return Icons.category;
  }
}

final Map<String, Color> categoryColors = {
  "Food": Colors.blue,
  "Transport": Colors.orange,
  "Shopping": Colors.red,
  "Bills": Colors.green,
  "Entertainment": Colors.purple,
  "Other": Colors.grey,
};
