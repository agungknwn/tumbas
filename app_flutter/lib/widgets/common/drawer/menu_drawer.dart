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
            child: Container(
              color: appTheme.secondary,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: appTheme.secondary,
                      image: DecorationImage(
                        image: AssetImage("assets/app_icon.png"),
                        fit: BoxFit.contain,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Spacer(), // push text to bottom
                        Text(
                          userId,
                          style: TextStyle(color: Colors.black87, fontSize: 24),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.monetization_on),
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
          ),

          // Bottom sect: Logout button
          Container(
            color: appTheme.secondary,
            child: Column(
              children: [
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text('Logout'),
                  onTap: _onLogoutPressed,
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
