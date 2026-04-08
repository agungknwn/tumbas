import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ngirit_app/providers/summaries_provider.dart';
import 'package:provider/provider.dart';

class ExpenseCategoryPieChart extends StatefulWidget {
  const ExpenseCategoryPieChart({super.key});

  @override
  State<StatefulWidget> createState() => ExpenseCategoryPieChartState();
}

class ExpenseCategoryPieChartState extends State {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SummariesProvider>();
    final categoryBreakdown = provider.monthlySummaries?.categories;
    if (categoryBreakdown == null) {
      return const CircularProgressIndicator();
    }
    final hasData = categoryBreakdown.entries.any((e) => e.value != 0);

    // debugPrint("categoryBreakdown: $categoryBreakdown");
    // debugPrint("categories: $categoryBreakdown");
    return AspectRatio(
      aspectRatio: 1.3,
      child: Column(
        children: <Widget>[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: buildTopInfo(categoryBreakdown),
          ),
          // buildTopInfo(),
          const SizedBox(height: 10),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: hasData
                      ? PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex = pieTouchResponse
                                      .touchedSection!
                                      .touchedSectionIndex;
                                });
                              },
                        )
                      : PieTouchData(enabled: false),
                  startDegreeOffset: 180,
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 4,
                  centerSpaceRadius: 6,
                  sections: showingSections(categoryBreakdown),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // final categories = [
  //   {
  //     "title": "Food",
  //     "value": 20.0,
  //     "color": Colors.blue,
  //     "icon": Icons.restaurant,
  //   },
  //   {
  //     "title": "Transport",
  //     "value": 10.0,
  //     "color": Colors.orange,
  //     "icon": Icons.directions_car,
  //   },
  //   {
  //     "title": "Shopping",
  //     "value": 30.0,
  //     "color": Colors.pink,
  //     "icon": Icons.shopping_bag,
  //   },
  //   {
  //     "title": "Bills",
  //     "value": 15.0,
  //     "color": Colors.green,
  //     "icon": Icons.receipt,
  //   },
  //   {
  //     "title": "Other",
  //     "value": 25.0,
  //     "color": Colors.grey,
  //     "icon": Icons.category,
  //   },
  // ];
  //

  Widget buildTopInfo(data) {
    if (touchedIndex == -1) {
      return const SizedBox(height: 40); // keep layout stable
      // return const SizedBox(height: 1); // keep layout stable
    }

    final categories = buildCategories(data);

    final item = categories[touchedIndex];
    // debugPrint("categories length: ${categories.length}");

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item["icon"] as IconData, color: item["color"] as Color),
          const SizedBox(width: 8),
          Text(
            "${item["title"]}: ${formatCurrency(item["value"] as double, "Rp. ")}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections(
    Map<String, double> categoryBreakdown,
  ) {
    final baseRadius = 65; // 30% rad
    // final radiusScale = <double>[1.0, 1.2, 0.9, 1.1, 1.0, 0.8];
    // final radiusValues = <double>[110, 90, 100, 110, 100, 80];

    //This can be removed because no title is being displayed in the first place
    final titlePositionPercentageOffsets = <double>[.5, .5, .5, .5, .5, .5];

    // final dataValues = <double>[20, 10, 30, 15, 25];
    // sort first
    final sortedEntries = categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // 👈 DESC
    //
    final rawValues = categoryBreakdown.values.toList();
    final dataValues = toPercentages(rawValues);
    final maxValue = dataValues.reduce((a, b) => a > b ? a : b);

    // final categoryList = categoryBreakdown.entries
    //     .where((e) => e.value != 0)
    //     .map((e) => e.key)
    //     .toList();
    final categoryList = sortedEntries.map((e) => e.key).toList();

    if (dataValues.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.grey.shade300,
          value: 1,
          title: "No data",
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
          radius: 100,
        ),
      ];
    }
    // debugPrint("data values: ${dataValues}");
    // debugPrint("data values length: ${dataValues.length}");

    return List.generate(dataValues.length, (i) {
      // debugPrint("touched index: $i");
      final isTouched = i == touchedIndex;
      final badgeSize = isTouched ? 55.0 : 40.0;
      final fontSize = isTouched ? 20.0 : 16.0;
      final dynamicRadius = isTouched ? baseRadius * 0.8 : baseRadius;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      return PieChartSectionData(
        color: categoryColors[categoryList[i]],
        // value: dataValues[i],
        value: (1 / dataValues.length) * 100,
        title: isTouched ? "" : formatPercent(dataValues[i]),
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
          shadows: shadows,
        ),
        radius: dynamicRadius + (dataValues[i] * baseRadius / maxValue),
        titlePositionPercentageOffset: titlePositionPercentageOffsets[i],
        badgeWidget: isTouched
            ? null
            : _Badge(
                icon: categoryIcons[categoryList[i]] ?? Icons.category,
                size: badgeSize,
                borderColor: categoryColors[categoryList[i]] ?? Colors.black,
              ),
        badgePositionPercentageOffset: .98,
        // borderSide: isTouched
        //     ? const BorderSide(color: AppColors.contentColorWhite, width: 6)
        //     : BorderSide(
        //         color: AppColors.contentColorWhite.withValues(alpha: 0),
        //       ),
        // Use a very thin border just for separation
        // borderSide: BorderSide(color: AppColors.contentColorWhite, width: 2),
      );
    });
  }
}

// helper func
class AppColors {
  static const contentColorBlue = Colors.blue;
  static const contentColorYellow = Colors.orange;
  static const contentColorPink = Colors.pink;
  static const contentColorGreen = Colors.green;

  static const contentColorWhite = Colors.white;

  static const mainTextColor1 = Colors.black;
  static const mainTextColor3 = Colors.grey;
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    required this.size,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(fontSize: size, color: textColor),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.size,
    required this.borderColor,
    required this.icon,
  });

  final IconData icon;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: .5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(child: Icon(icon, color: borderColor)),
    );
  }
}

String formatPercent(double value) {
  return value % 1 == 0 ? "${value.toInt()}%" : "${value.toStringAsFixed(1)}%";
}

String formatCurrency(double value, String currency) {
  return value % 1 == 0
      ? "$currency${value.toInt()}"
      : "$currency${value.toStringAsFixed(1)}";
}

// populate categories script
List<Map<String, dynamic>> buildCategories(Map<String, double> data) {
  final categoryBreakdownObjList = data.entries
      .where((e) => e.value != 0) // remove empty
      .map((e) {
        final value = e.value < 0 ? 0.0 : e.value; // 👈 important

        return {
          "title": e.key,
          "value": value,
          "color": categoryColors[e.key] ?? Colors.grey,
          "icon": categoryIcons[e.key] ?? Icons.category,
        };
      })
      .toList();

  categoryBreakdownObjList.sort(
    (a, b) => (b["value"] as double).compareTo(a["value"] as double),
  ); // 👈 DESC

  return categoryBreakdownObjList;
}

final Map<String, IconData> categoryIcons = {
  "Food": Icons.restaurant,
  "Transport": Icons.directions_car,
  "Shopping": Icons.shopping_bag,
  "Bills": Icons.receipt,
  "Entertainment": Icons.movie,
  "Other": Icons.category,
};

final Map<String, Color> categoryColors = {
  "Food": Colors.blue,
  "Transport": Colors.orange,
  "Shopping": Colors.teal,
  "Bills": Colors.green,
  "Entertainment": Colors.purple,
  "Other": Colors.grey,
};

// func: convert to percentage
double getTotal(List<double> values) {
  return values.fold(0.0, (sum, v) => sum + v);
}

List<double> toPercentages(List<double> values) {
  final total = getTotal(values);

  if (total == 0) return [];

  final percentages = values
      .map((v) => (v / total) * 100)
      .where((p) => p > 0) // 👈 remove 0%
      .toList();

  percentages.sort((a, b) => b.compareTo(a)); // 👈 DESC

  return percentages;
}
