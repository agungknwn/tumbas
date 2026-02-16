import 'package:flutter/material.dart';
import 'package:ngirit_app/models/expenses.dart';
import 'package:provider/provider.dart';
import 'package:ngirit_app/providers/expense_provider.dart';
import '../../widgets/common/datepicker.dart';

class ExpensesScreen extends StatefulWidget {
  // final Function(String, String, String)? onAddExpense;
  final String userId;
  // const ExpensesScreen({super.key});
  const ExpensesScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  late String selectedDate;
  String expenseListTitle = "Today Expenses";
  // String selectedDate = DateTime.now().toString().split(' ')[0];

  @override
  void initState() {
    super.initState();
    // This will be called when an expense is added from NavBar
    // No need to define addExpense here anymore
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final expenseProvider = context.read<ExpenseProvider>();

      DateTime currentDate = DateTime.now();
      expenseProvider.setDate(currentDate);

      selectedDate = currentDate.toString().split(' ')[0];
      // selectedDate = expenseProvider.selectedDate.toString().split(' ')[0];
      expenseProvider.fetchExpenses(widget.userId, selectedDate);
    });
  }

  void onDateChanged(DateTime newDate) {
    final formattedDate = newDate.toIso8601String().split('T').first;
    final expenseProvider = context.read<ExpenseProvider>();
    expenseProvider.setDate(newDate);
    expenseProvider.fetchExpenses(widget.userId, formattedDate);

    final now = DateTime.now();

    final isToday =
        expenseProvider.selectedDate.year == now.year &&
        expenseProvider.selectedDate.month == now.month &&
        expenseProvider.selectedDate.day == now.day;

    if (isToday) {
      expenseListTitle = "Today Expenses";
    } else {
      expenseListTitle = "Expenses List";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Blue header section
          ScreenHeader(),
          // Date picker aligned left
          Align(
            alignment: Alignment.centerLeft,
            child: DatePickerWidget(onDateSelected: onDateChanged),
          ),
          // White content section with overlap
          Expanded(
            child: Consumer<ExpenseProvider>(
              builder: (context, expenseProvider, child) {
                print('🔍 Provider state:');
                print('   - isLoading: ${expenseProvider.isLoading}');
                print(
                  '   - expenses count: ${expenseProvider.expenses.length}',
                );
                print('   - expenses: ${expenseProvider.expenses}');
                if (expenseProvider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                double total = expenseProvider.expenses.fold(
                  0,
                  (sum, expense) => sum + expense.amount,
                );

                return Stack(
                  children: [
                    // Total expenses card (overlapping)
                    SummaryCard(total: total),
                    ExpenseListHeader(title: expenseListTitle),
                    // Scrollable expense list
                    ExpenseList(expenses: expenseProvider.expenses),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}

class ExpenseList extends StatelessWidget {
  final List<ExpenseResponse> expenses;

  const ExpenseList({super.key, required this.expenses});

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
          return _expenseItem(
            item.name,
            item.category,
            'Rp. ${item.amount.toStringAsFixed(0)}',
          );
        },
      ),
    );
  }

  Widget _expenseItem(String title, String category, String price) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              Text(
                category,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          Text(
            price,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class ExpenseListHeader extends StatelessWidget {
  final String title;
  const ExpenseListHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 160, left: 24),
      child: Text(
        title,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final double total;

  const SummaryCard({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 24,
      right: 24,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: Colors.pink, width: 4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
              'Rp. ${total.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Daily Expenses",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            // AddExpensePopup(onAddItem: onAddItem),
          ],
        ),
      ),
    );
  }
}

class AddExpensePopup extends StatelessWidget {
  final Function(String title, String amount, String category) onAddItem;

  const AddExpensePopup({super.key, required this.onAddItem});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            final TextEditingController titleController =
                TextEditingController();
            final TextEditingController amountController =
                TextEditingController();

            List<String> categories = [
              "Food",
              "Transport",
              "Entertainment",
              "Housing",
              "Gifts",
              "Other",
            ];
            String selectedCategory =
                categories.first; // auto-select first category

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
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

                        Text(
                          "Category",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
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
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  onAddItem(
                                    titleController.text,
                                    amountController.text,
                                    selectedCategory,
                                  );
                                  Navigator.pop(context);
                                },
                                child: Text("Add Expense"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 24,
        child: Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
