import 'package:flutter/material.dart';

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
