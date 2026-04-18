import 'package:flutter/material.dart';
import 'package:ngirit_app/providers/budget_provider.dart';
import 'package:ngirit_app/providers/common_provider.dart';
import 'package:ngirit_app/providers/expense_provider.dart';
import 'package:ngirit_app/providers/summaries_provider.dart';
import 'package:ngirit_app/widgets/common/generic/dropdown.dart';
import 'package:ngirit_app/widgets/common/generic/ui_feedback.dart';
import 'package:provider/provider.dart';

class SetBudgetForm extends StatefulWidget {
  const SetBudgetForm({super.key});

  @override
  State<SetBudgetForm> createState() => SetBudgetFormState();
}

class SetBudgetFormState extends State<SetBudgetForm> {
  // late BudgetProvider _budgetProvider;

  final TextEditingController _amountController = TextEditingController();
  String _selectedCurrency = 'IDR';
  late String _baseCurrency;
  late double _currentBudget;

  // final List<String> currencies = ['USD', 'IDR', 'EUR', 'SEK'];
  @override
  void initState() {
    super.initState();

    final provider = context.read<BudgetProvider>();
    final budget = provider.userBudget;
    if (budget != null) {
      debugPrint("user budget: ${budget.currency}");
      _baseCurrency = budget.currency;
      _currentBudget = budget.amount;
    }

    if (budget != null) {
      _amountController.text = budget.amount.toString();
      _selectedCurrency = budget.currency;
    }
  }

  Future<void> onSetBudget(BudgetProvider provider) async {
    final newAmount = double.parse(_amountController.text);
    await provider.updateBudget(newAmount, _baseCurrency, _selectedCurrency);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<BudgetProvider>();
    final summariesProvider = context.read<SummariesProvider>();
    final expenseProvider = context.read<ExpenseProvider>();
    // final budget = provider.userBudget;
    final commonProvider = context.read<CommonProvider>();
    final currencies = commonProvider.currencyList;

    // if (budget != null) {
    //   _amountController.text = budget.amount.toString();
    //   _selectedCurrency = budget.currency;
    // }
    final appTheme = Theme.of(context).colorScheme;
    return AlertDialog(
      backgroundColor: appTheme.secondary,
      title: const Text('Set Monthly Budget'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // TextField(
          //   controller: _amountController,
          //   keyboardType: TextInputType.number,
          //   decoration: const InputDecoration(
          //     labelText: "Amount",
          //     border: OutlineInputBorder(),
          //   ),
          // ),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Amount",
              border: const OutlineInputBorder(),
              suffixIcon: commonProvider.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          AppDropdown(
            label: 'Currency',
            value: _selectedCurrency,
            items: currencies,
            onChanged: (value) async {
              final newCurrency = value!;

              setState(() {
                _selectedCurrency = newCurrency;
              });

              final exchangeRate = await commonProvider.getExchangeRate(
                _baseCurrency,
                newCurrency,
              );

              // final currentAmount =
              //     double.tryParse(_amountController.text) ?? 0;
              final currentAmount = _currentBudget;

              final converted = currentAmount * exchangeRate;

              setState(() {
                // _amountController.text = converted.toStringAsFixed(2);
                _amountController.text = converted.toString();
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appTheme.primary.withValues(alpha: 0.5),
                  minimumSize: const Size(120, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: appTheme.secondary),
                    SizedBox(width: 10),
                    Text("Cancel", style: TextStyle(color: appTheme.secondary)),
                  ],
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(120, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.attach_money, color: appTheme.secondary),
                    SizedBox(width: 10),
                    Text("Set", style: TextStyle(color: appTheme.secondary)),
                  ],
                ),
                onPressed: () async {
                  await onSetBudget(provider);

                  final date = DateTime.now();
                  // final formattedDate = date.toIso8601String().split('T').first;
                  await summariesProvider.getMonthlySummaries();
                  expenseProvider.setDateAndFetch(expenseProvider.userId, date);

                  if (context.mounted) {
                    Navigator.pop(context);
                    UiFeedback.show(
                      context,
                      message: "Budget and currency updated",
                      type: FeedbackType.success,
                    );
                  }
                  // debugPrint("fe currency: $_selectedCurrency");
                  // if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
