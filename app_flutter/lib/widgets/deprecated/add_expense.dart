import 'package:flutter/material.dart';

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
