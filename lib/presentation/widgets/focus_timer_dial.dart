import 'dart:math' as math;

import 'package:flutter/material.dart';

class FocusTimerDial extends StatelessWidget {
  final int minutes;
  final int seconds;
  final double progress;
  final String label;
  final bool isPaused;

  const FocusTimerDial({
    super.key,
    required this.minutes,
    required this.seconds,
    required this.progress,
    required this.label,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _FocusDialPainter(progress: progress),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeString,
                style: const TextStyle(
                  color: Color(0xFFF5F5F0),
                  fontSize: 68,
                  fontWeight: FontWeight.w600,
                  height: 0.95,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                isPaused ? 'Paused' : label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.58),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusDialPainter extends CustomPainter {
  final double progress;

  const _FocusDialPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 18;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12;

    final progressPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [Color(0xFFF4F1EA), Color(0xFF9F9F96), Color(0xFFF4F1EA)],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12;

    final innerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius - 24, innerPaint);
    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0, 1),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FocusDialPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
