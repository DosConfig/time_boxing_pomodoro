import 'dart:math' as math;

import 'package:flutter/material.dart';

class FocusMarkMotion extends StatelessWidget {
  final Duration duration;
  final bool animate;

  const FocusMarkMotion({
    super.key,
    this.duration = const Duration(milliseconds: 980),
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!animate) {
      return const CustomPaint(
        painter: FocusMarkMotionPainter(progress: 1),
        child: SizedBox.expand(),
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return CustomPaint(
          painter: FocusMarkMotionPainter(progress: value),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class FocusMarkMotionPainter extends CustomPainter {
  final double progress;

  const FocusMarkMotionPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final clampedProgress = progress.clamp(0.0, 1.0).toDouble();
    final eased = Curves.easeOutCubic.transform(clampedProgress);
    final settle = Curves.easeOutBack.transform(clampedProgress);
    final center = Offset(size.width / 2, size.height / 2);
    final side = math.min(size.width, size.height) * 0.78;
    final scale = side / 1024;
    final radius = Radius.circular(224 * scale);
    final iconRect = Rect.fromCenter(center: center, width: side, height: side);
    final iconRRect = RRect.fromRectAndRadius(iconRect, radius);
    final markColor = const Color(0xFFF6F3EC);
    final backgroundPaint = Paint()..color = const Color(0xFF080808);
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, 2.6 * scale)
      ..color = Colors.white.withValues(alpha: 0.16 * eased);

    _drawFlyingFragments(canvas, center, scale, markColor, eased);

    canvas.save();
    final iconScale = 0.92 + (0.08 * settle);
    canvas.translate(center.dx, center.dy);
    canvas.scale(iconScale);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawRRect(iconRRect, backgroundPaint);
    canvas.drawRRect(iconRRect, borderPaint);
    _drawFocusMark(canvas, center, scale, markColor, eased);
    canvas.restore();
  }

  void _drawFlyingFragments(
    Canvas canvas,
    Offset center,
    double scale,
    Color color,
    double eased,
  ) {
    final opacity = ((1 - eased) * 0.32).clamp(0.0, 0.32).toDouble();
    if (opacity <= 0) {
      return;
    }

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 26 * scale
      ..color = color.withValues(alpha: opacity);
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18 * scale
      ..color = color.withValues(alpha: opacity * 0.62);
    final dotPaint = Paint()..color = color.withValues(alpha: opacity * 0.82);
    final outerRect = Rect.fromCircle(center: center, radius: 286 * scale);
    final innerRect = Rect.fromCircle(center: center, radius: 178 * scale);

    canvas.save();
    canvas.translate((1 - eased) * -120 * scale, (1 - eased) * 36 * scale);
    canvas.rotate((1 - eased) * -0.24);
    canvas.drawArc(outerRect, -math.pi * 0.72, math.pi * 0.62, false, arcPaint);
    canvas.restore();

    canvas.save();
    canvas.translate((1 - eased) * 132 * scale, (1 - eased) * -42 * scale);
    canvas.rotate((1 - eased) * 0.2);
    canvas.drawArc(innerRect, math.pi * 0.12, math.pi * 0.86, false, ringPaint);
    canvas.restore();

    canvas.drawCircle(
      center + Offset((1 - eased) * 96 * scale, (1 - eased) * 84 * scale),
      22 * scale,
      dotPaint,
    );
  }

  void _drawFocusMark(
    Canvas canvas,
    Offset center,
    double scale,
    Color color,
    double eased,
  ) {
    final outerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 56 * scale
      ..color = color.withValues(alpha: 0.22 * eased);
    final innerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40 * scale
      ..color = color.withValues(alpha: 0.34 * eased);
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 72 * scale
      ..color = color.withValues(alpha: eased);
    final dotPaint = Paint()..color = color.withValues(alpha: eased);
    final outerRadius = 286 * scale;
    final innerRadius = 178 * scale;
    final dotRadius = 58 * scale * (0.84 + (0.16 * eased));

    canvas.drawCircle(center, outerRadius, outerRingPaint);
    canvas.drawCircle(center, innerRadius, innerRingPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      -math.pi / 2,
      (math.pi / 2) * eased,
      false,
      arcPaint,
    );
    canvas.drawCircle(center, dotRadius, dotPaint);
  }

  @override
  bool shouldRepaint(covariant FocusMarkMotionPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
