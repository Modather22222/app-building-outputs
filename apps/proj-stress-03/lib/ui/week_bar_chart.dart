import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'format.dart';

/// Simple custom-painted bar chart showing spending for the last 7 days.
class WeekBarChart extends StatelessWidget {
  const WeekBarChart({super.key, required this.values});

  /// One total per day, oldest first; the last entry is today.
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final labels = [
      for (var i = values.length - 1; i >= 0; i--)
        weekdayLabel(now.subtract(Duration(days: i))),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last 7 days', style: textTheme.titleSmall),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              width: double.infinity,
              child: CustomPaint(
                painter: _BarsPainter(
                  values: values,
                  barColor: scheme.primary.withAlpha(90),
                  highlightColor: scheme.primary,
                  baselineColor: scheme.outlineVariant,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                for (final label in labels)
                  Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: textTheme.labelSmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({
    required this.values,
    required this.barColor,
    required this.highlightColor,
    required this.baselineColor,
  });

  final List<double> values;
  final Color barColor;
  final Color highlightColor;
  final Color baselineColor;

  @override
  void paint(Canvas canvas, Size size) {
    var maxValue = 0.0;
    for (final value in values) {
      if (value > maxValue) maxValue = value;
    }

    final baselinePaint = Paint()
      ..color = baselineColor
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height - 0.5),
      Offset(size.width, size.height - 0.5),
      baselinePaint,
    );

    final slot = size.width / values.length;
    final barWidth = slot * 0.5;
    for (var i = 0; i < values.length; i++) {
      final ratio = maxValue <= 0 ? 0.0 : values[i] / maxValue;
      final barHeight = (size.height - 8) * ratio;
      final left = slot * i + (slot - barWidth) / 2;
      final rect = Rect.fromLTWH(
        left,
        size.height - barHeight,
        barWidth,
        math.max(barHeight, 2),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(5)),
        Paint()..color = i == values.length - 1 ? highlightColor : barColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter oldDelegate) => true;
}
