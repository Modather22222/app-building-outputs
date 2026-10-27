import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const StopwatchApp());
}

class StopwatchApp extends StatelessWidget {
  const StopwatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Build Info Probe',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const StopwatchPage(),
    );
  }
}

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  final List<Duration> _laps = [];

  bool get _running => _stopwatch.isRunning;

  void _startPause() {
    setState(() {
      if (_running) {
        _stopwatch.stop();
        _ticker?.cancel();
        _ticker = null;
      } else {
        _stopwatch.start();
        _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) {
          setState(() {});
        });
      }
    });
  }

  void _lap() {
    if (_stopwatch.elapsedMilliseconds == 0) return;
    setState(() => _laps.insert(0, _stopwatch.elapsed));
  }

  void _reset() {
    _ticker?.cancel();
    _ticker = null;
    setState(() {
      _stopwatch.reset();
      _laps.clear();
    });
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hundredths = (d.inMilliseconds.remainder(1000) ~/ 10)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds.$hundredths';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final display = _format(_stopwatch.elapsed);
    return Scaffold(
      appBar: AppBar(title: const Text('Stopwatch')),
      body: Column(
        children: [
          const SizedBox(height: 32),
          Text(
            display,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.tonalIcon(
                onPressed: _running ? _lap : null,
                icon: const Icon(Icons.flag),
                label: const Text('Lap'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _startPause,
                icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                label: Text(_running ? 'Pause' : 'Start'),
              ),
              const SizedBox(width: 12),
              FilledButton.tonalIcon(
                onPressed:
                    _laps.isNotEmpty || _stopwatch.elapsedMilliseconds > 0
                        ? _reset
                        : null,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
            ],
          ),
          const Divider(height: 32),
          Expanded(
            child: _laps.isEmpty
                ? Center(
                    child: Text(
                      'No laps yet — press Lap while running.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    itemCount: _laps.length,
                    itemBuilder: (context, index) {
                      final lapNumber = _laps.length - index;
                      final lapTime = _laps[index];
                      final delta = lapNumber == _laps.length
                          ? lapTime
                          : lapTime - _laps[_laps.length - lapNumber];
                      return ListTile(
                        leading: Text('Lap $lapNumber'),
                        title: Text(
                          _format(lapTime),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        trailing: Text('+${_format(delta)}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
