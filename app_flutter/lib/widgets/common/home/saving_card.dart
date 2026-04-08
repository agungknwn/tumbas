import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../animated/shiny_sparkle.dart';
import '../animated/shiny_text.dart';
import 'package:velocity_x/velocity_x.dart';

class SavingCard extends StatelessWidget {
  final double amountSaved;
  final double total;
  final bool isLoading;

  const SavingCard({
    super.key,
    required this.amountSaved,
    required this.total,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final amountSpent = total - amountSaved;
    final percentage = total > 0 ? (amountSaved / total * 100).toInt() : 0;
    final progress = total > 0 ? (amountSaved / total).clamp(0.0, 1.0) : 0.0;
    final appTheme = Theme.of(context).colorScheme;

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 2,
    );

    Color getProgressColor(double progress) {
      if (progress > 0.5) {
        return Colors.green;
      } else if (progress > 0.25) {
        return Colors.yellow;
      } else {
        return Colors.red;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // gradient: const LinearGradient(
        //   colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
        borderRadius: BorderRadius.circular(20),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.blue.withOpacity(0.3),
        //     blurRadius: 10,
        //     offset: const Offset(0, 5),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          // velocity x example
          // "Monthly Saving".text.xl4
          //     .color(context.primaryColor)
          //     .center
          //     .make()
          //     .centered(),
          Row(
            mainAxisSize: MainAxisSize.min, // 👈 important
            children: [
              Stack(
                clipBehavior: Clip.none, // 👈 allow overflow (fix cropping)
                children: [
                  // TweenAnimationBuilder(
                  //   tween: Tween(begin: 0.8, end: 1.1),
                  //   duration: Duration(milliseconds: 1000),
                  //   curve: Curves.fastEaseInToSlowEaseOut,
                  //   builder: (context, scale, child) {
                  //     return Transform.scale(scale: scale, child: child);
                  //   },
                  //   child: "Monthly Saving".text.xl4.extraBold.tightest
                  //       .make()
                  //       .shaderMask(
                  //         gradient: LinearGradient(
                  //           colors: [
                  //             context.primaryColor,
                  //             context.primaryColor.withOpacity(0.7),
                  //           ],
                  //         ),
                  //       ),
                  // ),
                  ShinyText("Monthly Saving"),

                  Positioned(
                    right: -20,
                    top: -6,
                    // decoration: BoxDecoration(
                    //   boxShadow: [
                    //     BoxShadow(
                    //       color: context.primaryColor.withOpacity(0.5),
                    //       blurRadius: 12,
                    //       spreadRadius: 2,
                    //     ),
                    //   ],
                    // ),
                    child: ShinySparkle(),
                    // child: TweenAnimationBuilder(
                    //   tween: Tween(begin: 0.8, end: 1.5),
                    //   duration: Duration(seconds: 2),
                    //   curve: Curves.easeInOut,
                    //   builder: (context, scale, child) {
                    //     return Transform.scale(scale: scale, child: child);
                    //   },
                    //   child: Icon(
                    //     Icons.auto_awesome,
                    //     size: 18,
                    //     color: context.primaryColor,
                    //   ),
                    // ),
                  ),
                ],
              ),
            ],
          ).centered().p16(), // Align(
          //   alignment: Alignment.center,
          //   child: Text(
          //     'Monthly Saving',
          //     textAlign: TextAlign.center,
          //     style: TextStyle(
          //       color: Theme.of(context).colorScheme.secondary,
          //       fontSize: 32,
          //       fontWeight: FontWeight.w500,
          //     ),
          //   ),
          // ),
          const SizedBox(height: 12),

          // Amount spent and total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormatter.format(amountSaved),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // const SizedBox(width: 28),
              // const Spacer(),
              Text(
                'of ${currencyFormatter.format(total)}',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),

              // Padding(
              //   padding: const EdgeInsets.only(bottom: 8),
              //   child: Text(
              //     'of \$${total.toStringAsFixed(2)}',
              //     style: TextStyle(
              //       color: Colors.black.withOpacity(0.7),
              //       fontSize: 14,
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.black.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                getProgressColor(progress),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Remaining amount and percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Money Used: ${currencyFormatter.format(amountSpent)}',
                style: TextStyle(
                  color: appTheme.primary.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  color: appTheme.primary.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
