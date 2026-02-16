import 'package:flutter/material.dart';

class SavingCard extends StatelessWidget {
  final double amountSaved;
  final double total;

  const SavingCard({super.key, required this.amountSaved, required this.total});

  @override
  Widget build(BuildContext context) {
    if (total == 0) {
      return const Center(child: CircularProgressIndicator());
    }
    final amountSpent = total - amountSaved;
    final percentage = (amountSaved / total * 100).toInt();
    final progress = (amountSaved / total).clamp(0.0, 1.0);

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
          Align(
            alignment: Alignment.center,
            child: const Text(
              'Monthly Saving',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 32,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Amount spent and total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${amountSaved.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // const SizedBox(width: 28),
              // const Spacer(),
              Text(
                'of \$${total.toStringAsFixed(2)}',
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
                'Money Used: \$${amountSpent.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.9),
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
