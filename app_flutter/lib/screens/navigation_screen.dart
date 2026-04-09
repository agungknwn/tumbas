import 'package:flutter/material.dart';
import 'package:ngirit_app/providers/auth_provider.dart';
import 'package:ngirit_app/screens/auth/login_screen.dart';
import '../widgets/common/drawer/menu_drawer.dart';
import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
import 'package:ngirit_app/screens/feature/home_screen.dart';
import '../../widgets/common/popup/expense_form.dart';
import '../providers/expense_provider.dart';
import 'feature/expenses_screen.dart';
import '../widgets/common/generic/bottom_navbar.dart';
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
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final now = DateTime.now();
    //   context.read<ExpenseProvider>().setUserId(widget.userId);
    //   context.read<ExpenseProvider>().setDateAndFetch(widget.userId, now);
    // });
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
            child: ExpenseForm(
              userId: widget.userId,
              editMode: false,
              submitText: "Add Expense",
              deleteText: "",
              onAddExpense: () {
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
                Navigator.pop(context, true);

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

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context).colorScheme;
    final provider = context.read<AuthProvider>();

    // nav bar item
    final List<NavItem> navItems = [
      NavItem(Icons.home, 'Home'),
      NavItem(Icons.money_rounded, 'Expenses'),
    ];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: AppDrawer(
        userId: widget.userId,
        onLogout: () {
          provider.userLogout();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
          // debugPrint('logout done');
        },
      ),
      body: _pages[_selectedIndex],

      // Floating Action Button (Center Circle Button)
      floatingActionButton: FloatingActionButton(
        onPressed: _onCenterButtonPressed,
        elevation: 4,
        backgroundColor: appTheme.tertiary,
        foregroundColor: appTheme.primary,
        hoverColor: appTheme.secondary.withValues(alpha: 0.3),
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavBar(
        items: navItems,
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
    // return bottomNavBarV1();
  }
}
