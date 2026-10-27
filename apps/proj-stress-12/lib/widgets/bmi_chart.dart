import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/bmi_entry.dart';

/// Trend chart of BMI measurements with the healthy 18.5-25 band shaded.
///
/// Drawn with a [CustomPainter] so the app needs no chart dependency.
class BmiChart extends StatelessWidget {
  const BmiChart({super.key, required this.entries});

  final List<BmiEntry> entries;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 180,
      child: CustomPaint(
        size: Size.infinite,
        painter: _BmiChartPainter(
          entries: entries,
          lineColor: scheme.primary,
          bandColor: Colors.green.withValues(alpha: 0.15),
          bandLineColor: Colors.green.withValues(alpha: 0.5),
          gridColor: scheme.outlineVariant,
          labelColor: scheme.onSurfaceVariant,
          textStyle: Theme.of(context).textTheme.bodySmall ?? const TextStyle(fontSize: 11),
        ),
      ),
    );
  }
}

enum _LabelAnchor { leftCenter, rightCenter, aboveRight }

class _BmiChartPainter extends CustomPainter {
  _BmiChartPainter({
    required this.entries,
    required this.lineColor,
    required this.bandColor,
    required this.bandLineColor,
    required this.gridColor,
    required this.labelColor,
    required this.textStyle,
  });

  final List<BmiEntry> entries;
  final Color lineColor;
  final Color bandColor;
  final Color bandLineColor;
  final Color gridColor;
  final Color labelColor;
  final TextStyle textStyle;

  static const double _healthyMin = 18.5;
  static const double _healthyMax = 25.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    final List<double> values = <double>[for (final BmiEntry e in entries) e.bmi];
    final double dataMin = values.reduce(math.min);
    final double dataMax = values.reduce(math.max);

    // Pad the vertical domain and always keep the healthy band in view.
    final double low = math.min(16.0, dataMin - 1.5);
    final double high = math.max(31.0, dataMax + 1.5);

    const double leftPad = 40;
    const double rightPad = 44;
    const double topPad = 14;
    const double bottomPad = 14;
    final Rect plot = Rect.fromLTWH(
      leftPad,
      topPad,
      math.max(1, size.width - leftPad - rightPad),
      math.max(1, size.height - topPad - bottomPad),
    );

    double yFor(double value) =>
        plot.bottom - ((value - low) / (high - low)) * plot.height;

    // Healthy band + edge lines.
    final Rect band = Rect.fromLTRB(
      plot.left,
      yFor(_healthyMax),
      plot.right,
      yFor(_healthyMin),
    );
    canvas.drawRect(band, Paint()..color = bandColor);
    final Paint edge = Paint()
      ..color = bandLineColor
      ..strokeWidth = 1;
    canvas.drawLine(Offset(plot.left, band.top), Offset(plot.right, band.top), edge);
    canvas.drawLine(Offset(plot.left, band.bottom), Offset(plot.right, band.bottom), edge);
    _drawLabel(canvas, '25', Offset(plot.left - 4, band.top), _LabelAnchor.rightCenter);
    _drawLabel(canvas, '18.5', Offset(plot.left - 4, band.bottom), _LabelAnchor.rightCenter);

    // Baseline.
    canvas.drawLine(
      Offset(plot.left, plot.bottom),
      Offset(plot.right, plot.bottom),
      Paint()..color = gridColor..strokeWidth = 1,
    );

    final List<Offset> points = <Offset>[
      for (int i = 0; i < values.length; i++)
        Offset(
          values.length == 1
              ? plot.center.dx
              : plot.left + plot.width * (i / (values.length - 1)),
          yFor(values[i]),
        ),
    ];

    if (points.length > 1) {
      final Path path = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 3.5, Paint()..color = lineColor);
    }

    // Highlight + label the most recent value.
    final Offset last = points.last;
    canvas.drawCircle(last, 5.5, Paint()..color = lineColor);
    canvas.drawCircle(last, 3.5, Paint()..color = Colors.white);
    _drawLabel(
      canvas,
      values.last.toStringAsFixed(1),
      Offset(plot.right, last.dy - 8),
      _LabelAnchor.aboveRight,
    );
  }

  void _drawLabel(Canvas canvas, String text, Offset anchor, _LabelAnchor anchorType) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: textStyle.copyWith(color: labelColor)),
      textDirection: TextDirection.ltr,
    )..layout();

    double dx;
    double dy;
    switch (anchorType) {
      case _LabelAnchor.leftCenter:
        dx = anchor.dx;
        dy = anchor.dy - painter.height / 2;
      case _LabelAnchor.rightCenter:
        dx = anchor.dx - painter.width;
        dy = anchor.dy - painter.height / 2;
      case _LabelAnchor.aboveRight:
        dx = anchor.dx - painter.width;
        dy = anchor.dy;
    }
    painter.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(_BmiChartPainter oldDelegate) =>
      oldDelegate.entries != entries ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.bandColor != bandColor ||
      oldDelegate.bandLineColor != bandLineColor ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.labelColor != labelColor;
}
