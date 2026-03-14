import 'package:flutter/material.dart';
import 'package:ngirit_app/providers/expense_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ExpenseForm extends StatefulWidget {
  final String userId;
  final String? expenseId;
  final String submitText;
  final String deleteText;

  // form mode
  final bool editMode;

  // for callback
  final Function? onAddExpense;
  final Function? onSubmit;
  final Function? onDelete;
  final Function? onOpen;

  const ExpenseForm({
    super.key,
    required this.userId,
    required this.submitText,
    required this.deleteText,
    required this.editMode,
    this.expenseId,
    this.onAddExpense,
    this.onSubmit,
    this.onDelete,
    this.onOpen,
  });

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  bool _isInitialized = false;
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

  @override
  void initState() {
    super.initState();
    if (widget.expenseId != null) {
      widget.onOpen?.call(widget.expenseId!);
    }
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
      widget.onAddExpense!();
    }
  }

  void _handleSubmit(BuildContext context) async {
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

    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    await provider.updateExpense(
      widget.expenseId!,
      titleController.text,
      selectedCategory,
      amount,
    );

    // final now = DateTime.now().toIso8601String().split("T")[0];
    // await provider.fetchExpenses(provider.userId, now);

    // Call optional callback
    if (widget.onSubmit != null) {
      widget.onSubmit!();
    }
  }

  void _handleDelete(BuildContext context) async {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final now = provider.selectedDate.toIso8601String().split(' ')[0];

    await provider.deleteExpense(widget.expenseId!);

    await provider.fetchExpenses(provider.userId, now);
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    if (expenseProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (!_isInitialized &&
        widget.expenseId != null &&
        expenseProvider.editExpense != null) {
      final targetExpense = expenseProvider.editExpense!;
      titleController.text = targetExpense.name;
      amountController.text = targetExpense.amount.toString();
      selectedCategory = targetExpense.category;
      _isInitialized = true;
    }
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
            if (widget.editMode)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _handleDelete(context),
                child: Text(widget.deleteText),
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
                    onPressed: () {
                      if (widget.onSubmit != null) {
                        _handleSubmit(context);
                      } else if (widget.onAddExpense != null) {
                        _handleAddExpense(context);
                      }
                    },
                    child: Text(widget.submitText),
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
