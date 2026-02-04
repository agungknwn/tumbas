import 'package:flutter/material.dart';
import 'package:ngirit_app/widgets/datepicker.dart';

class ExpensesScreen extends StatefulWidget {
  final Function(String, String, String)? onAddExpense;
  // const ExpensesScreen({super.key});
  const ExpensesScreen({Key? key, this.onAddExpense}) : super(key: key);

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  List<Map<String, String>> expenses = [
    {"title": "Fried Rice", "category": "food", "price": "Rp. 15.000"},
  ];

  @override
  void initState() {
    super.initState();
    // This will be called when an expense is added from NavBar
    // No need to define addExpense here anymore
  }

  void addExpense(String title, String amount, String category) {
    setState(() {
      expenses.add({
        "title": title,
        "category": category,
        "price": "Rp." + amount,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Blue header section
          ScreenHeader(onAddItem: addExpense),
          // Date picker aligned left
          Align(alignment: Alignment.centerLeft, child: DatePickerWidget()),
          // White content section with overlap
          Expanded(
            child: Stack(
              children: [
                // Total expenses card (overlapping)
                SummaryCard(),
                ExpenseListHeader(),
                // Scrollable expense list
                ExpenseList(expenses: expenses),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}

class ExpenseList extends StatelessWidget {
  final List<Map<String, String>> expenses;

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
            item["title"]!,
            item["category"]!,
            item["price"]!,
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
  const ExpenseListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 160, left: 24),
      child: Text(
        'Today Expenses',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key});

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
              'Rp. 50,000',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class ScreenHeader extends StatelessWidget {
  final Function(String title, String amount, String category) onAddItem;

  const ScreenHeader({super.key, required this.onAddItem});

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
            AddExpensePopup(onAddItem: onAddItem),
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
