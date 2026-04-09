import 'package:ngirit_app/providers/budget_provider.dart';
import 'package:ngirit_app/providers/common_provider.dart';
import 'package:ngirit_app/providers/summaries_provider.dart';
import 'package:ngirit_app/widgets/common/charts/category_expense_pie_cart.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../widgets/common/home/home_header.dart';
// import '../../widgets/common/menu_drawer.dart';
import '../../widgets/common/home/saving_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> currencies = ['IDR', 'USD', 'EUR', 'SEK'];
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SummariesProvider>().getMonthlySummaries();
      // context.read<BudgetProvider>().fetchBudget();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context).colorScheme;
    final summariesProvider = context.watch<SummariesProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final commonProvider = context.watch<CommonProvider>();

    // debugPrint('selected currency: ${commonProvider.selectedCurrency}');
    final double totalMonthlySpending =
        summariesProvider.monthlySummaries?.totalExpenses ?? 0.0;
    final double totalBudget = budgetProvider.userBudget?.amount ?? 0.0;
    final double savingAmount = totalBudget - totalMonthlySpending;

    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          HomeHeader(
            currentMonthYear: summariesProvider.monthYear,
            currencies: currencies,
          ),
          SavingCard(
            amountSaved: savingAmount,
            total: totalBudget,
            isLoading: budgetProvider.isLoading,
            currency: commonProvider.selectedCurrency,
          ),

          // SizedBox(height: 5),
          // Padding(
          //   padding: const EdgeInsets.all(12),
          //   child: Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          //     decoration: BoxDecoration(
          //       color: Colors.black.withOpacity(0.8),
          //       borderRadius: BorderRadius.circular(16),
          //       border: Border.all(color: Colors.black.withOpacity(0.15)),
          //     ),
          //     child: Row(
          //       children: [
          //         Icon(Icons.pie_chart, color: Colors.white.withOpacity(0.8)),
          //         SizedBox(width: 10),
          //         Text(
          //           "Expense by Category",
          //           style: TextStyle(
          //             fontSize: 18,
          //             fontWeight: FontWeight.w600,
          //             color: Colors.white,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Container(
                //   width: 4,
                //   height: 28,
                //   decoration: BoxDecoration(
                //     color: appTheme.tertiary,
                //     borderRadius: BorderRadius.circular(2),
                //   ),
                // ),
                // const SizedBox(width: 12),
                Icon(Icons.pie_chart, color: Colors.black.withOpacity(0.8)),
                SizedBox(width: 10),
                Text(
                  "Expense By Category",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: appTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          ExpenseCategoryPieChart(currency: commonProvider.selectedCurrency),
        ],
      ),
    );
  }
}
