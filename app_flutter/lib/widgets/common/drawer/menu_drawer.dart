import 'package:flutter/material.dart';
import 'set_budget_form.dart';

class AppDrawer extends StatelessWidget {
  final String userId;
  final Function? onLogout;
  const AppDrawer({super.key, required this.userId, this.onLogout});

  void _onLogoutPressed() {
    if (onLogout != null) {
      onLogout!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme appTheme = Theme.of(context).colorScheme;
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: appTheme.tertiary),
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
          ),

          // Bottom sect: Logout button
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout'),
            onTap: _onLogoutPressed,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
