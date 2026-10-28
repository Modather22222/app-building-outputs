import 'dart:async';

import 'package:flutter/material.dart';

import '../format.dart';

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  final Stopwatch _watch = Stopwatch();
  final List<Duration> _laps = [];
  Timer? _ticker;

  bool get _running => _watch.isRunning;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      if (_running) {
        _watch.stop();
        _ticker?.cancel();
        _ticker = null;
      } else {
        _watch.start();
        _ticker = Timer.periodic(const Duration(milliseconds: 30), (_) {
          if (mounted) setState(() {});
        });
      }
    });
  }

  void _lap() {
    setState(() => _laps.insert(0, _watch.elapsed));
  }

  void _reset() {
    setState(() {
      _watch.reset();
      _laps.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final running = _running;
    final hasTime = _watch.elapsed > Duration.zero;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Text(
              stopwatchText(_watch.elapsed),
              key: const ValueKey('stopwatch-time'),
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: scheme.onSurface,
              ),
            ),
            const Spacer(),
            Expanded(
              flex: 3,
              child: _laps.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _laps.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final total = _laps[i];
                        final previous =
                            i + 1 < _laps.length ? _laps[i + 1] : Duration.zero;
                        final split = total - previous;
                        return ListTile(
                          dense: true,
                          leading: Text(
                            'Lap ${_laps.length - i}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          title: Text(
                            stopwatchText(split),
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          trailing: Text(
                            stopwatchText(total),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: running
                        ? _lap
                        : (hasTime ? _reset : null),
                    icon: Icon(running ? Icons.flag : Icons.refresh),
                    label: Text(running ? 'Lap' : 'Reset'),
                  ),
                  FilledButton.icon(
                    onPressed: _toggle,
                    icon: Icon(running ? Icons.pause : Icons.play_arrow),
                    label: Text(running ? 'Pause' : 'Start'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
