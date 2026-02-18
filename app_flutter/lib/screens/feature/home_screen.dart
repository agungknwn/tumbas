import 'package:ngirit_app/providers/budget_provider.dart';
import 'package:ngirit_app/providers/summaries_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:ngirit_app/widgets/common/home_header.dart';
// import '../../widgets/common/menu_drawer.dart';
import '../../widgets/common/saving_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    final summariesProvider = context.watch<SummariesProvider>();
    final budgetProvider = context.watch<BudgetProvider>();

    final double totalMonthlySpending =
        summariesProvider.monthlySummaries?.totalExpenses ?? 0.0;
    final double totalBudget = budgetProvider.userBudget?.amount ?? 0.0;
    final double savingAmount = totalBudget - totalMonthlySpending;

    print("Spent Amount: $totalMonthlySpending");

    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          HomeHeader(
            currentMonthYear: summariesProvider.monthYear,
            currencies: ['IDR', 'USD', 'EUR'],
          ),
          SavingCard(
            amountSaved: savingAmount,
            total: totalBudget,
            isLoading: budgetProvider.isLoading,
          ),
        ],
      ),
    );
  }
}
