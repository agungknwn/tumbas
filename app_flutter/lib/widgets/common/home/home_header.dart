import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String currentMonthYear;
  final List<String> currencies;
  const HomeHeader({
    super.key,
    required this.currentMonthYear,
    required this.currencies,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme appTheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 34, 12, 10),
      decoration: BoxDecoration(
        color: appTheme.primary,
        border: Border.all(color: Colors.black87),
      ),
      child: Row(
        children: [
          // Icon(Icons.menu, size: 20, color: Colors.white),
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(Icons.menu, size: 20, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          const SizedBox(width: 16),
          // month year text
          Text(
            currentMonthYear,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const Spacer(),

          // const currencies = <String>['IDR', 'USD', 'EUR'];
          //Dropdown currency
          DropdownButton<String>(
            value: 'IDR',
            style: TextStyle(color: Colors.black87),
            underline: SizedBox(),
            icon: Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
            items: currencies.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            selectedItemBuilder: (context) {
              return currencies.map((value) {
                return Center(
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList();
            },
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }
}
