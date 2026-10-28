import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnalogClock extends StatelessWidget {
  const AnalogClock({super.key, required this.now, required this.size});

  final DateTime now;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AnalogClockPainter(
          now: now,
          handColor: scheme.onSurface,
          accentColor: scheme.tertiary,
        ),
      ),
    );
  }
}

class _AnalogClockPainter extends CustomPainter {
  _AnalogClockPainter({
    required this.now,
    required this.handColor,
    required this.accentColor,
  });

  final DateTime now;
  final Color handColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = handColor.withValues(alpha: 0.05),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = handColor.withValues(alpha: 0.25),
    );

    for (var i = 0; i < 60; i++) {
      final angle = i * 2 * math.pi / 60 - math.pi / 2;
      final major = i % 5 == 0;
      final dir = Offset(math.cos(angle), math.sin(angle));
      final start = center + dir * (radius * (major ? 0.82 : 0.90));
      final end = center + dir * (radius * 0.96);
      canvas.drawLine(
        start,
        end,
        Paint()
          ..strokeWidth = major ? 2.5 : 1
          ..color = handColor.withValues(alpha: major ? 0.55 : 0.3),
      );
    }

    const labels = ['12', '3', '6', '9'];
    final angles = [-math.pi / 2, 0.0, math.pi / 2, math.pi];
    final numeralStyle = TextStyle(
      fontSize: radius * 0.15,
      fontWeight: FontWeight.w600,
      color: handColor.withValues(alpha: 0.8),
    );
    for (var i = 0; i < labels.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: numeralStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final dir = Offset(math.cos(angles[i]), math.sin(angles[i]));
      tp.paint(
        canvas,
        center + dir * (radius * 0.68) - Offset(tp.width / 2, tp.height / 2),
      );
    }

    final hourAngle =
        ((now.hour % 12) + now.minute / 60) * 2 * math.pi / 12 - math.pi / 2;
    final minuteAngle =
        (now.minute + now.second / 60) * 2 * math.pi / 60 - math.pi / 2;
    final secondAngle =
        (now.second + now.millisecond / 1000) * 2 * math.pi / 60 - math.pi / 2;

    _drawHand(canvas, center, hourAngle, radius * 0.5, 6, handColor);
    _drawHand(canvas, center, minuteAngle, radius * 0.72, 4, handColor);
    _drawHand(canvas, center, secondAngle, radius * 0.80, 2, accentColor);

    canvas.drawCircle(center, 5, Paint()..color = handColor);
    canvas.drawCircle(
      center,
      2.5,
      Paint()..color = accentColor,
    );
  }

  void _drawHand(Canvas canvas, Offset center, double angle, double length,
      double width, Color color) {
    final dir = Offset(math.cos(angle), math.sin(angle));
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center - dir * (length * 0.15), center + dir * length, paint);
  }

  @override
  bool shouldRepaint(_AnalogClockPainter oldDelegate) =>
      oldDelegate.now != now || oldDelegate.handColor != handColor;
}
