import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      // padding: const EdgeInsets.fromLTRB(12, 34, 12, 0),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
      decoration: BoxDecoration(
        color: appTheme.primary,
        // border: Border.all(color: Colors.black87),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Icon(Icons.menu, size: 20, color: Colors.white),
            Builder(
              builder: (context) {
                return Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/app_icon_inverse.png',
                        height: 50,
                        width: 50,
                      ),
                    ),
                  ),
                );
                // return IconButton(
                //   // icon: Icon(Icons.menu, size: 20, color: Colors.white),
                //   icon: ClipRRect(
                //     borderRadius: BorderRadius.circular(
                //       8,
                //     ), // Rounds the actual image corners
                //     child: Image.asset(
                //       'assets/app_icon_inverse.png',
                //       height: 50,
                //       width: 50,
                //       // fit: BoxFit.cover,
                //     ),
                //   ),
                //   onPressed: () {
                //     Scaffold.of(context).openDrawer();
                //   },
                // );
              },
            ),
            Icon(Icons.arrow_forward_sharp, color: Colors.white),
            const SizedBox(width: 8),
            // month year text
            Text(
              formatMonthYear(currentMonthYear),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
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
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
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
      ),
    );
  }
}

// helper func
String formatMonthYear(String input) {
  DateTime dateTime = DateFormat("yyyy-MM").parse(input);

  return DateFormat("MMMM yyyy").format(dateTime);
}
