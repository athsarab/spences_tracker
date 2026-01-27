import 'package:flutter/material.dart';

/// Low-opacity abstract finance illustration.
///
/// This is intentionally subtle (no busy patterns) and designed to work
/// behind text, especially for onboarding and empty states.
class FinanceIllustration extends StatelessWidget {
  const FinanceIllustration({
    super.key,
    required this.tone,
  });

  final Color tone;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FinanceIllustrationPainter(tone: tone),
      size: const Size(double.infinity, 160),
    );
  }
}

class _FinanceIllustrationPainter extends CustomPainter {
  const _FinanceIllustrationPainter({required this.tone});

  final Color tone;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;

    // Soft “coin” circles.
    final coinPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = tone.withValues(alpha: 0.16);

    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.42), 22, coinPaint);
    canvas.drawCircle(Offset(size.width * 0.28, size.height * 0.50), 14, coinPaint);
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.34), 18, coinPaint);

    // A calm line chart (single polyline + dots).
    paint
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = tone.withValues(alpha: 0.22);

    final path = Path();
    final points = <Offset>[
      Offset(size.width * 0.18, size.height * 0.90),
      Offset(size.width * 0.34, size.height * 0.68),
      Offset(size.width * 0.50, size.height * 0.74),
      Offset(size.width * 0.66, size.height * 0.52),
      Offset(size.width * 0.82, size.height * 0.58),
    ];

    path.moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = tone.withValues(alpha: 0.28);

    for (final p in points) {
      canvas.drawCircle(p, 3.2, dotPaint);
    }

    // Subtle “bars” on the right.
    final barPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = tone.withValues(alpha: 0.10);

    final barWidth = 10.0;
    final baseY = size.height * 0.92;
    final xs = [0.86, 0.90, 0.94];
    final hs = [0.18, 0.28, 0.22];

    for (var i = 0; i < xs.length; i++) {
      final x = size.width * xs[i];
      final h = size.height * hs[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, baseY - h, barWidth, h),
          const Radius.circular(8),
        ),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FinanceIllustrationPainter oldDelegate) {
    return oldDelegate.tone != tone;
  }
}
