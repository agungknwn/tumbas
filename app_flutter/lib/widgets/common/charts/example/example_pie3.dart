import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartSample3 extends StatefulWidget {
  const PieChartSample3({super.key});

  @override
  State<StatefulWidget> createState() => PieChartSample3State();
}

class PieChartSample3State extends State {
  int touchedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: AspectRatio(
        aspectRatio: 1,
        child: PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    touchedIndex = -1;
                    return;
                  }
                  touchedIndex =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              },
            ),
            borderData: FlBorderData(show: false),
            sectionsSpace: 0,
            centerSpaceRadius: 0,
            sections: showingSections(),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 110.0 : 100.0;
      final widgetSize = isTouched ? 55.0 : 40.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      return switch (i) {
        0 => PieChartSectionData(
          color: AppColors.contentColorBlue,
          value: 40,
          title: '40%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff),
            shadows: shadows,
          ),
          badgeWidget: _Badge(
            'assets/icons/ophthalmology-svgrepo-com.svg',
            size: widgetSize,
            borderColor: AppColors.contentColorBlack,
          ),
          badgePositionPercentageOffset: .98,
        ),
        1 => PieChartSectionData(
          color: AppColors.contentColorYellow,
          value: 30,
          title: '30%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff),
            shadows: shadows,
          ),
          badgeWidget: _Badge(
            'assets/icons/librarian-svgrepo-com.svg',
            size: widgetSize,
            borderColor: AppColors.contentColorBlack,
          ),
          badgePositionPercentageOffset: .98,
        ),
        2 => PieChartSectionData(
          color: AppColors.contentColorPurple,
          value: 16,
          title: '16%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff),
            shadows: shadows,
          ),
          badgeWidget: _Badge(
            'assets/icons/fitness-svgrepo-com.svg',
            size: widgetSize,
            borderColor: AppColors.contentColorPurple,
          ),
          badgePositionPercentageOffset: .98,
        ),
        3 => PieChartSectionData(
          color: AppColors.contentColorGreen,
          value: 15,
          title: '15%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff),
            shadows: shadows,
          ),
          badgeWidget: _Badge(
            'assets/icons/worker-svgrepo-com.svg',
            size: widgetSize,
            borderColor: AppColors.contentColorBlack,
          ),
          badgePositionPercentageOffset: .98,
        ),
        _ => throw StateError('Invalid'),
      };
    });
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.svgAsset, {required this.size, required this.borderColor});

  final String svgAsset;
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
      child: Center(
        child: Icon(Icons.currency_ruble_rounded, color: borderColor),
      ),
    );
  }
}

class AppColors {
  static const contentColorBlue = Colors.blue;
  static const contentColorYellow = Colors.orange;
  static const contentColorPink = Colors.pink;
  static const contentColorGreen = Colors.green;
  static const contentColorPurple = Colors.purple;
  static const contentColorBlack = Colors.black;

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
