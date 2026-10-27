import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../state/weight_store.dart';
import '../util/ui.dart';

class TrendChart extends StatelessWidget {
  const TrendChart({super.key, required this.entries});

  final List<WeightEntry> entries;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (entries.length < 2) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.show_chart, size: 44, color: scheme.outline),
            const SizedBox(height: 8),
            Text(
              'Log at least two days to see your trend',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: CustomPaint(
        painter: _TrendPainter(
          entries: entries,
          line: scheme.primary,
          grid: scheme.outlineVariant,
          label: scheme.onSurfaceVariant,
          dotStroke: scheme.surface,
          textScaler: MediaQuery.textScalerOf(context),
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.entries,
    required this.line,
    required this.grid,
    required this.label,
    required this.dotStroke,
    required this.textScaler,
  });

  final List<WeightEntry> entries;
  final Color line;
  final Color grid;
  final Color label;
  final Color dotStroke;
  final TextScaler textScaler;

  @override
  void paint(Canvas canvas, Size size) {
    final weights = entries.map((e) => e.weight).toList(growable: false);
    var lo = weights.reduce(math.min);
    var hi = weights.reduce(math.max);
    if (hi - lo < 0.5) {
      lo -= 0.5;
      hi += 0.5;
    }
    final pad = (hi - lo) * 0.15;
    lo -= pad;
    hi += pad;

    const top = 12.0;
    const bottomInset = 26.0;
    const leftInset = 44.0;
    const rightInset = 12.0;
    final chartBottom = size.height - bottomInset;
    final chartHeight = chartBottom - top;
    final chartWidth = size.width - leftInset - rightInset;

    Offset pointAt(int i) {
      final t = i / (entries.length - 1);
      final v = (entries[i].weight - lo) / (hi - lo);
      return Offset(leftInset + chartWidth * t, chartBottom - chartHeight * v);
    }

    final gridPaint = Paint()
      ..color = grid.withValues(alpha: 0.7)
      ..strokeWidth = 1;
    for (final value in [lo, (lo + hi) / 2, hi]) {
      final y = chartBottom - (value - lo) / (hi - lo) * chartHeight;
      canvas.drawLine(
        Offset(leftInset, y),
        Offset(leftInset + chartWidth, y),
        gridPaint,
      );
      _label(
        canvas,
        value.toStringAsFixed(1),
        Offset(leftInset - 6, y),
        rightAligned: true,
        centered: true,
      );
    }

    final linePath = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < entries.length; i++) {
      linePath.lineTo(pointAt(i).dx, pointAt(i).dy);
    }

    final fill = Path.from(linePath)
      ..lineTo(pointAt(entries.length - 1).dx, chartBottom)
      ..lineTo(pointAt(0).dx, chartBottom)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [line.withValues(alpha: 0.25), line.withValues(alpha: 0.02)],
        ).createShader(Rect.fromLTWH(0, top, size.width, chartHeight)),
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (var i = 0; i < entries.length; i++) {
      final p = pointAt(i);
      canvas.drawCircle(p, 4, Paint()..color = dotStroke);
      canvas.drawCircle(p, 2.5, Paint()..color = line);
    }

    _label(
      canvas,
      formatDay(entries.first.date),
      Offset(leftInset, size.height - 18),
      rightAligned: false,
    );
    _label(
      canvas,
      formatDay(entries.last.date),
      Offset(size.width - rightInset, size.height - 18),
      rightAligned: true,
    );
  }

  void _label(
    Canvas canvas,
    String text,
    Offset anchor, {
    required bool rightAligned,
    bool centered = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: label, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )..layout();
    var dx = anchor.dx;
    if (rightAligned) dx -= tp.width;
    var dy = anchor.dy;
    if (centered) dy -= tp.height / 2;
    tp.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(_TrendPainter oldDelegate) =>
      oldDelegate.entries != entries ||
      oldDelegate.line != line ||
      oldDelegate.grid != grid ||
      oldDelegate.label != label ||
      oldDelegate.dotStroke != dotStroke;
}
