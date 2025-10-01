import 'package:flutter/material.dart';
import 'dart:math' as math;

class CRTTimerWidget extends StatefulWidget {
  final int minutes;
  final int seconds;
  final Color screenColor;
  final Color textColor;

  const CRTTimerWidget({
    super.key,
    required this.minutes,
    required this.seconds,
    this.screenColor = const Color(0xFF0a3a2a),
    this.textColor = const Color(0xFF33ff88),
  });

  @override
  State<CRTTimerWidget> createState() => _CRTTimerWidgetState();
}

class _CRTTimerWidgetState extends State<CRTTimerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didUpdateWidget(CRTTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.minutes != widget.minutes || oldWidget.seconds != widget.seconds) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeString = '${widget.minutes.toString().padLeft(2, '0')}:${widget.seconds.toString().padLeft(2, '0')}';
    final totalSeconds = widget.minutes * 60 + widget.seconds;
    final maxSeconds = 25 * 60; // 25분
    final progress = totalSeconds / maxSeconds;

    return Container(
      width: 400,
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[800]!, width: 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // CRT Screen Background
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    widget.screenColor,
                    widget.screenColor.withOpacity(0.8),
                    Colors.black,
                  ],
                ),
              ),
            ),
            // Progress Bar at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 8,
                color: Colors.black.withOpacity(0.5),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.textColor,
                          widget.textColor.withOpacity(0.6),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.textColor.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Scanlines
            CustomPaint(
              painter: ScanlinePainter(),
              size: Size.infinite,
            ),
            // CRT Curvature Effect
            CustomPaint(
              painter: CRTCurvaturePainter(),
              size: Size.infinite,
            ),
            // Timer Text with fade animation
            Center(
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.7, end: 1.0).animate(
                  CurvedAnimation(parent: _controller, curve: Curves.easeOut),
                ),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                    CurvedAnimation(parent: _controller, curve: Curves.easeOut),
                  ),
                  child: Text(
                    timeString,
                    style: TextStyle(
                      fontFamily: 'DOSIyagi',
                      fontSize: 80,
                      color: widget.textColor,
                      shadows: [
                        Shadow(
                          color: widget.textColor.withOpacity(0.8),
                          blurRadius: 20,
                        ),
                        Shadow(
                          color: widget.textColor.withOpacity(0.5),
                          blurRadius: 40,
                        ),
                      ],
                      letterSpacing: 8,
                    ),
                  ),
                ),
              ),
            ),
            // Screen Flicker Effect
            CustomPaint(
              painter: FlickerPainter(),
              size: Size.infinite,
            ),
          ],
        ),
      ),
    );
  }
}

class ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..strokeWidth = 1;

    for (double i = 0; i < size.height; i += 3) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CRTCurvaturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.3),
          Colors.black.withOpacity(0.6),
        ],
        stops: const [0.0, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FlickerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(DateTime.now().millisecondsSinceEpoch);
    final opacity = 0.02 + random.nextDouble() * 0.03;

    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
