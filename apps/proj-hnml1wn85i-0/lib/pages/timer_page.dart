import 'dart:async';

import 'package:flutter/material.dart';

import '../format.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  static const Duration _tick = Duration(milliseconds: 100);

  Timer? _ticker;
  Duration _selected = const Duration(minutes: 5);
  Duration _remaining = const Duration(minutes: 5);
  DateTime? _endAt;
  bool _started = false;
  bool _finished = false;

  bool get _running => _ticker != null;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() {
      _started = true;
      _finished = false;
      _remaining = _selected;
      _endAt = DateTime.now().add(_selected);
      _startTicker();
    });
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(_tick, (_) => _onTick());
  }

  void _onTick() {
    if (!mounted || _endAt == null) return;
    final left = _endAt!.difference(DateTime.now());
    if (left <= Duration.zero) {
      _ticker?.cancel();
      _ticker = null;
      setState(() {
        _remaining = Duration.zero;
        _finished = true;
      });
    } else {
      setState(() => _remaining = left);
    }
  }

  void _pause() {
    _ticker?.cancel();
    _ticker = null;
    setState(() => _remaining = _endAt!.difference(DateTime.now()));
  }

  void _resume() {
    setState(() {
      _endAt = DateTime.now().add(_remaining);
      _startTicker();
    });
  }

  void _reset() {
    _ticker?.cancel();
    _ticker = null;
    setState(() {
      _started = false;
      _finished = false;
      _remaining = _selected;
    });
  }

  void _setSelected(Duration d) {
    setState(() {
      _selected = d;
      _remaining = d;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final minutes = _selected.inMinutes;
    final seconds = _selected.inSeconds.remainder(60);
    final progress = _selected > Duration.zero
        ? (_remaining.inMilliseconds / _selected.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 260,
                      height: 260,
                      child: CircularProgressIndicator(
                        value: _started ? progress : 1,
                        strokeWidth: 10,
                        strokeCap: StrokeCap.round,
                        color: _finished
                            ? scheme.error
                            : scheme.primary,
                      ),
                    ),
                    Text(
                      countdownText(_remaining),
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              _finished ? "Time's up!" : 'Timer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _finished ? scheme.error : scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            if (!_started)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Slider(
                      value: minutes.clamp(0, 59).toDouble(),
                      min: 0,
                      max: 59,
                      divisions: 59,
                      label: '$minutes min',
                      onChanged: (v) => _setSelected(
                        Duration(
                          minutes: v.round(),
                          seconds: seconds,
                        ),
                      ),
                    ),
                    Slider(
                      value: (seconds ~/ 5).toDouble() * 5,
                      min: 0,
                      max: 55,
                      divisions: 11,
                      label: '$seconds sec',
                      onChanged: (v) => _setSelected(
                        Duration(
                          minutes: minutes,
                          seconds: v.round(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!_started)
                    FilledButton.icon(
                      onPressed:
                          _selected > Duration.zero ? _start : null,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start'),
                    )
                  else ...[
                    FilledButton.tonalIcon(
                      onPressed: _running ? _pause : _resume,
                      icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                      label: Text(_running ? 'Pause' : 'Resume'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
