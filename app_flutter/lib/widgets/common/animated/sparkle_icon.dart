import 'package:flutter/material.dart';

class SparkleIcon extends StatefulWidget {
  const SparkleIcon({super.key});

  @override
  State<SparkleIcon> createState() => _SparkleIconState();
}

class _SparkleIconState extends State<SparkleIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true); // 👈 infinite loop

    scale = Tween(
      begin: 0.8,
      end: 1.5,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale,
      child: Icon(
        Icons.auto_awesome,
        size: 18,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
