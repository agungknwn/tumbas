import 'package:flutter/material.dart';
import 'package:ngirit_app/widgets/common/set_budget_form.dart';

class AppDrawer extends StatelessWidget {
  final String userId;
  const AppDrawer({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Text(
              userId,
              style: TextStyle(color: Colors.black87, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Set Budget'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => SetBudgetForm(),
              );
            },
          ),
        ],
      ),
    );
  }
}
