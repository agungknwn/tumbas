import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class ShinyText extends StatefulWidget {
  final String text;
  const ShinyText(this.text, {super.key});

  @override
  State<ShinyText> createState() => _ShinyTextState();
}

class _ShinyTextState extends State<ShinyText>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    // controller = AnimationController(
    //   vsync: this,
    //   duration: const Duration(milliseconds: 2000), // slower = premium feel
    // )..repeat(); // 🔁 infinite shine
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _startAnimation();
  }

  // Custom loop with a 1-second pause at the end
  void _startAnimation() async {
    if (!mounted) return;
    await controller.forward(from: 0.0);
    await Future.delayed(const Duration(milliseconds: 1500)); // The "Cooldown"
    _startAnimation();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context).colorScheme;
    final baseColor = appTheme.primary;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            double offset = (controller.value * 6.0) - 3.0;
            return LinearGradient(
              begin: Alignment(offset - 1.0, -1.5),
              end: Alignment(offset + 1.0, 1.5),
              colors: [
                baseColor,
                baseColor.withOpacity(0.5),
                Colors.white, // ✨ shine streak
                baseColor.withOpacity(0.5),
                baseColor,
              ],
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
              // tileMode: TileMode.mirror,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: widget.text.text.xl4.extraBold.tightest.make(),
        );
      },
    );
  }
}
