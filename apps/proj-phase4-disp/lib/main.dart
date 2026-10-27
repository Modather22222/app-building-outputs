import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const DispatchProbeApp());
}

class DispatchProbeApp extends StatelessWidget {
  const DispatchProbeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dispatch Probe',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: const TapCounterPage(),
    );
  }
}

class TapCounterPage extends StatefulWidget {
  const TapCounterPage({super.key});

  @override
  State<TapCounterPage> createState() => _TapCounterPageState();
}

class _TapCounterPageState extends State<TapCounterPage> {
  int _count = 0;

  void _increment() {
    setState(() {
      _count++;
    });
    HapticFeedback.mediumImpact();
  }

  void _reset() {
    setState(() {
      _count = 0;
    });
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispatch Probe'),
        actions: [
          IconButton(
            tooltip: 'Reset counter',
            icon: const Icon(Icons.restart_alt),
            onPressed: _count == 0 ? null : _reset,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Taps',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    letterSpacing: 2,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_count',
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
            ),
            const SizedBox(height: 32),
            FilledButton.tonal(
              onPressed: _increment,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text('Tap', style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
