import 'package:flutter/material.dart';
import 'package:ngirit_app/providers/expense_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AddExpenseForm extends StatefulWidget {
  final String userId;
  final Function(String title, String amount, String category)? onAddExpense;

  const AddExpenseForm({Key? key, required this.userId, this.onAddExpense})
    : super(key: key);

  @override
  State<AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<AddExpenseForm> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  String selectedCategory = "Food";

  final List<String> categories = [
    "Food",
    "Transport",
    "Shopping",
    "Entertainment",
    "Bills",
    "Other",
  ];

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _handleAddExpense(BuildContext context) async {
    // Validate inputs
    if (titleController.text.isEmpty || amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    // Parse amount
    final int? amount = int.tryParse(amountController.text);
    if (amount == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a valid amount')));
      return;
    }

    // Format dates
    // final selectedDate = context.read<ExpenseProvider>().selectedDate;
    final selectedDate = DateTime.now();

    final String date = DateFormat('yyyy-MM-dd').format(selectedDate);
    final String monthYear = DateFormat('yyyy-MM').format(selectedDate);

    // Get provider and add expense
    final expenseProvider = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );

    await expenseProvider.addNewExpense(
      widget.userId,
      amount,
      selectedCategory,
      titleController.text,
      date,
      monthYear,
    );

    // Call optional callback
    if (widget.onAddExpense != null) {
      widget.onAddExpense!(
        titleController.text,
        amountController.text,
        selectedCategory,
      );
    }

    // Close dialog
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            "Add New Expense",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(height: 20),

        TextField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: "Expense title",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        SizedBox(height: 12),

        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Amount",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        SizedBox(height: 16),

        Text("Category", style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 8),

        Wrap(
          spacing: 10,
          children: categories.map((cat) {
            final bool active = selectedCategory == cat;
            return ChoiceChip(
              label: Text(cat),
              selected: active,
              onSelected: (_) {
                setState(() => selectedCategory = cat);
              },
              selectedColor: Colors.blue,
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color: active ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            );
          }).toList(),
        ),

        SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Consumer<ExpenseProvider>(
                builder: (context, expenseProvider, child) {
                  if (expenseProvider.isLoading) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: null,
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    );
                  }
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _handleAddExpense(context),
                    child: Text("Add Expense"),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
