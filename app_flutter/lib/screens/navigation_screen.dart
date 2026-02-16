import 'package:flutter/material.dart';
import '../widgets/common/menu_drawer.dart';
import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
import 'package:ngirit_app/screens/feature/home_screen.dart';
import '../../widgets/common/add_expense_form.dart';
import '../providers/expense_provider.dart';
import 'feature/expenses_screen.dart';
// import 'feature/account_screen.dart';
// import 'package:ngirit_app/utils/counter_be.dart';

// Main Screen Navigator
class NavigationScreen extends StatefulWidget {
  final Function(String, String, String)? onAddExpense; // Add this paramete
  final String userId;

  const NavigationScreen({
    super.key,
    required this.userId,
    required this.onAddExpense,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  DateTime currentDate = DateTime.now();
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      // ExpensesScreen(),
      HomeScreen(),
      ExpensesScreen(userId: widget.userId), // Pass it here
      // MyCounterPage(title: widget.userId),
    ];
  }

  void _onCenterButtonPressed() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: AddExpenseForm(
              userId: widget.userId,
              onAddExpense: (title, amount, category) {
                final expenseProvider = context.read<ExpenseProvider>();
                // Optional: Refresh expenses after adding
                Provider.of<ExpenseProvider>(
                  context,
                  listen: false,
                ).fetchExpenses(
                  widget.userId,
                  // DateFormat('yyyy-MM-dd').format(expenseProvider.selectedDate),
                  currentDate.toString().split(' ')[0],
                );
                expenseProvider.setDate(currentDate);
                setState(() {
                  _selectedIndex = 1;
                });

                // print("Title: $title, Amount: $amount, Category: $category");
              },
            ),
          ),
        );
      },
    );
  }
  // final List<Widget> _pages = [
  //   ExpensesScreen(),
  //   const MyCounterPage(title: widget.userId),
  //   AccountScreen(),
  // ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Future<bool> _onWillPop() async {
  //   return await showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           title: const Text("Exit Confirmation"),
  //           content: const Text("Are you sure want to quit?"),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context, false),
  //               child: const Text("Cancel"),
  //             ),
  //             ElevatedButton(
  //               onPressed: () {
  //                 Navigator.pop(context, true);
  //               },
  //               child: const Text("Quit"),
  //             ),
  //           ],
  //         ),
  //       ) ??
  //       false;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(userId: widget.userId),
      body: _pages[_selectedIndex],

      // Floating Action Button (Center Circle Button)
      floatingActionButton: FloatingActionButton(
        onPressed: _onCenterButtonPressed,
        elevation: 4,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Home Button
              Expanded(
                child: InkWell(
                  onTap: () => _onItemTapped(0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home,
                        color: _selectedIndex == 0 ? Colors.blue : Colors.grey,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Home',
                        style: TextStyle(
                          color: _selectedIndex == 0
                              ? Colors.blue
                              : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Spacer for center button
              const SizedBox(width: 80),

              // Settings Button
              Expanded(
                child: InkWell(
                  onTap: () => _onItemTapped(1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.money_rounded,
                        color: _selectedIndex == 1 ? Colors.blue : Colors.grey,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Expenses',
                        style: TextStyle(
                          color: _selectedIndex == 1
                              ? Colors.blue
                              : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    // return bottomNavBarV1();
  }
}
