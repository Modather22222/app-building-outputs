import 'dart:async';

import 'package:flutter/material.dart';

import '../format.dart';
import '../widgets/analog_clock.dart';

class ClockPage extends StatefulWidget {
  const ClockPage({super.key});

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  late DateTime _now = DateTime.now();
  bool _use24h = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final displayHour = _use24h
        ? clockText(_now, use24h: true)
        : '${clockText(_now, use24h: false)} ${meridiem(_now)}';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnalogClock(now: _now, size: 260),
              const SizedBox(height: 32),
              Text(
                displayHour,
                key: const ValueKey('digital-clock'),
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                longDate(_now),
                style: TextStyle(
                  fontSize: 16,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('12 h')),
                  ButtonSegment(value: true, label: Text('24 h')),
                ],
                selected: {_use24h},
                onSelectionChanged: (s) => setState(() => _use24h = s.first),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
