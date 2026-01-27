import 'package:flutter/material.dart';

class AnimatedLinearProgress extends StatelessWidget {
  const AnimatedLinearProgress({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 420),
    this.minHeight = 10,
    this.backgroundColor,
    this.color,
    this.borderRadius = 999,
  });

  final double value;
  final Duration duration;
  final double minHeight;
  final Color? backgroundColor;
  final Color? color;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        return LinearProgressIndicator(
          value: v,
          minHeight: minHeight,
          borderRadius: BorderRadius.circular(borderRadius),
          backgroundColor: backgroundColor,
          color: color,
        );
      },
    );
  }
}

class AnimatedCircularProgress extends StatelessWidget {
  const AnimatedCircularProgress({
    super.key,
    required this.value,
    this.size = 56,
    this.strokeWidth = 8,
    this.duration = const Duration(milliseconds: 520),
    this.backgroundColor,
    this.color,
  });

  final double value;
  final double size;
  final double strokeWidth;
  final Duration duration;
  final Color? backgroundColor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: v,
            strokeWidth: strokeWidth,
            backgroundColor: backgroundColor,
            color: color,
          ),
        );
      },
    );
  }
}
