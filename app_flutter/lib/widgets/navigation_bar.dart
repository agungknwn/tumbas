import 'package:flutter/material.dart';
import 'package:ngirit_app/screens/expenses_screen.dart';
import 'package:ngirit_app/screens/account_screen.dart';
import 'package:ngirit_app/utils/counter_be.dart';

// Main Screen Navigator
class ScreenNavigation extends StatefulWidget {
  final Function(String, String, String)? onAddExpense; // Add this paramete
  final String userId;

  const ScreenNavigation({
    super.key,
    required this.userId,
    required this.onAddExpense,
  });

  @override
  State<ScreenNavigation> createState() => _ScreenNavigationState();
}

class _ScreenNavigationState extends State<ScreenNavigation> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      // ExpensesScreen(),
      ExpensesScreen(onAddExpense: widget.onAddExpense), // Pass it here
      MyCounterPage(title: widget.userId),
      AccountScreen(),
    ];
  }

  void _onCenterButtonPressed() {
    // Show the dialog here in NavBar
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController titleController = TextEditingController();
        final TextEditingController amountController = TextEditingController();

        List<String> categories = [
          "Food",
          "Transport",
          "Entertainment",
          "Other",
        ];
        String selectedCategory = categories.first;

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
                              // Call the callback if it exists
                              if (widget.onAddExpense != null) {
                                widget.onAddExpense!(
                                  titleController.text,
                                  amountController.text,
                                  selectedCategory,
                                );
                              }
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

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Exit Confirmation"),
            content: const Text("Are you sure want to quit?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text("Quit"),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return bottomNavBarV2(_onCenterButtonPressed);
    // return bottomNavBarV1();
  }

  Scaffold bottomNavBarV2(onButtonPressed) {
    return Scaffold(
      body: _pages[_selectedIndex],

      // Floating Action Button (Center Circle Button)
      floatingActionButton: FloatingActionButton(
        onPressed: onButtonPressed,
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
                        Icons.settings,
                        color: _selectedIndex == 1 ? Colors.blue : Colors.grey,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Settings',
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
  }

  WillPopScope bottomNavBarV1() {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.blue,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money),
              label: 'Expenses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
          ],
        ),
      ),
    );
  }
}
