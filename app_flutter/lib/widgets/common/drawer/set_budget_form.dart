import 'package:flutter/material.dart';
import 'package:ngirit_app/providers/budget_provider.dart';
import 'package:provider/provider.dart';

class SetBudgetForm extends StatefulWidget {
  const SetBudgetForm({super.key});

  @override
  State<SetBudgetForm> createState() => _SetBudgetFormState();
}

class _SetBudgetFormState extends State<SetBudgetForm> {
  late BudgetProvider _budgetProvider;

  final TextEditingController _amountController = TextEditingController();
  String _selectedCurrency = 'IDR';

  final List<String> currencies = ['USD', 'IDR', 'EUR'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _budgetProvider = context.read<BudgetProvider>();

      _budgetProvider.fetchBudget();

      _budgetProvider.addListener(() {
        final userBudget = _budgetProvider.userBudget;
        if (userBudget != null) {
          setState(() {
            _amountController.text = userBudget.amount.toString();
            _selectedCurrency = userBudget.currency;
          });
        }
      });
    });
  }

  void onSetBudget() {
    final newAmount = double.parse(_amountController.text);
    _budgetProvider.updateBudget(newAmount, _selectedCurrency);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Monthly Budget'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Amount",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCurrency,
            items: currencies
                .map(
                  (currency) =>
                      DropdownMenuItem(value: currency, child: Text(currency)),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCurrency = value!;
              });
            },
            decoration: const InputDecoration(
              labelText: "Currency",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("Set"),
                onPressed: () {
                  onSetBudget();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
