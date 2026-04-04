import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class NavItem {
  final IconData icon;
  final String label;
  NavItem(this.icon, this.label);
}

class BottomNavBar extends StatelessWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final Function onItemTapped;
  const BottomNavBar({
    super.key,
    required this.items,
    required this.onItemTapped,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme appTheme = Theme.of(context).colorScheme;
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: appTheme.primary,
      elevation: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var entry in items.asMap().entries) ...[
              if (entry.key == 1) const SizedBox(width: 80),

              Expanded(
                child: InkWell(
                  onTap: () => onItemTapped(entry.key),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        entry.value.icon,
                        color: selectedIndex == entry.key
                            ? appTheme.tertiary
                            : appTheme.secondary,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      // valocity x syntax
                      entry.value.label.text
                          .size(12)
                          .color(
                            selectedIndex == entry.key
                                ? appTheme.tertiary
                                : appTheme.secondary,
                          )
                          .make(),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
