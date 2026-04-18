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
  final ScrollController _chipScrollController = ScrollController();
  final Map<String, GlobalKey> _chipKeys = {};
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
    _chipScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _scrollToChip(selectedCategory);
    // });
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

  void _handleSubmit(BuildContext context) {
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

    // Call optional callback
    if (widget.onSubmit != null) {
      widget.onSubmit!(
        widget.expenseId,
        titleController.text,
        amount,
        selectedCategory,
      );
    }
  }

  void _scrollToChip(String cat) {
    final key = _chipKeys[cat];
    final context = key?.currentContext;
    if (context == null) return;

    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.0,
    );
  }

  void _handleDelete(BuildContext context) {
    if (widget.onDelete != null) {
      widget.onDelete!(widget.expenseId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context).colorScheme;
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

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToChip(selectedCategory);
      });
      // debugPrint("init cat: $selectedCategory");
      _isInitialized = true;
    }
    return Container(
      color: appTheme.secondary,
      child: Column(
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: 12),

          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Amount",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: 16),

          Text("Category", style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),

          // scroll view categories
          ClipRRect(
            borderRadius: BorderRadius.circular(25), // row radius
            child: IntrinsicHeight(
              // forces all children to match tallest
              child: SingleChildScrollView(
                controller: _chipScrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch, // stretch to IntrinsicHeight
                  children: categories.map((cat) {
                    _chipKeys[cat] ??= GlobalKey();
                    final bool active = selectedCategory == cat;
                    return Padding(
                      key: _chipKeys[cat],
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => selectedCategory = cat);
                          _scrollToChip(cat);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: active
                                ? appTheme.tertiary
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(
                              25,
                            ), // chip radius
                            border: Border.all(
                              color: active
                                  ? appTheme.tertiary
                                  : appTheme.primary,
                              width: 0.5,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                getCategoryIcon(cat),
                                size: 16,
                                color: active ? appTheme.primary : Colors.black,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                cat,
                                style: TextStyle(
                                  color: active
                                      ? appTheme.primary
                                      : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Wrap(
          //   spacing: 10,
          //   runSpacing: 12,
          //   children: categories.map((cat) {
          //     final bool active = selectedCategory == cat;
          //     return ChoiceChip(
          //       // label: Text(cat),
          //       label: Row(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           Icon(Icons.circle, size: 16),
          //           const SizedBox(width: 5),
          //           Text(cat),
          //         ],
          //       ),
          //       selected: active,
          //       onSelected: (_) {
          //         setState(() => selectedCategory = cat);
          //       },
          //       selectedColor: appTheme.tertiary,
          //       backgroundColor: Colors.grey.shade200,
          //       // labelPadding: EdgeInsetsGeometry.all(5),
          //       labelStyle: TextStyle(
          //         color: active ? appTheme.primary : Colors.black,
          //         fontWeight: FontWeight.w500,
          //       ),
          //     );
          //   }).toList(),
          // ),
          SizedBox(height: 24),

          Row(
            children: [
              if (widget.editMode)
                // OutlinedButton(
                //   style: OutlinedButton.styleFrom(
                //     padding: EdgeInsets.symmetric(vertical: 14),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //   ),
                //   onPressed: () => _handleDelete(context),
                //   child: Text(widget.deleteText),
                // ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.red, // red button
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide.none, // remove outline border
                  ),
                  onPressed: () => _handleDelete(context),
                  child: const Icon(
                    Icons.delete_outlined,
                    size: 28,
                    color: Colors.white, // white icon
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
                        backgroundColor: widget.editMode
                            ? Colors.blue
                            : Colors.green,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.editMode
                                ? Icons.edit_document
                                : Icons.add_card,
                            size: 20,
                            color: appTheme.secondary,
                          ),
                          SizedBox(width: 10),
                          Text(
                            widget.submitText,
                            style: TextStyle(color: appTheme.secondary),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
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
