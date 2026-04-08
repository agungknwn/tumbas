import 'package:flutter/material.dart';

class ShinySparkle extends StatefulWidget {
  const ShinySparkle({super.key});

  @override
  State<ShinySparkle> createState() => _ShinySparkleState();
}

class _ShinySparkleState extends State<ShinySparkle>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // 🔁 infinite loop
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final width = bounds.width;

            // 👇 animate gradient position
            final dx = controller.value * width * 2;

            return LinearGradient(
              begin: Alignment(-1 + controller.value * 2, 0),
              end: Alignment(1 + controller.value * 2, 0),
              colors: [
                baseColor.withOpacity(0.6),
                Colors.white, // ✨ shine streak
                baseColor.withOpacity(0.6),
              ],
              stops: const [0.4, 0.5, 0.6],
            ).createShader(bounds.shift(Offset(dx - width, 0)));
          },
          child: Icon(Icons.auto_awesome, size: 25, color: baseColor),
        );
      },
    );
  }
}
