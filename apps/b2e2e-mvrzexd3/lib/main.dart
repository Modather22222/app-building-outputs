import 'package:flutter/material.dart';

void main() {
  runApp(const B2VerificationApp());
}

class B2VerificationApp extends StatelessWidget {
  const B2VerificationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'B2 Verification',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: const ConverterScreen(),
    );
  }
}

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  static const double _milesPerKm = 0.621371;

  final TextEditingController _controller = TextEditingController();
  double? _kilometers;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() {
      _kilometers = double.tryParse(_controller.text.trim().replaceAll(',', '.'));
    });
  }

  double? get _miles {
    final km = _kilometers;
    if (km == null) return null;
    return km * _milesPerKm;
  }

  String _format(double value) {
    String s = value.toStringAsFixed(4);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '');
      if (s.endsWith('.')) s = s.substring(0, s.length - 1);
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final km = _kilometers;
    final miles = _miles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kilometers → Miles'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.swap_horiz,
                size: 72,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Kilometers',
                  hintText: 'Enter a distance, e.g. 5 or 12.5',
                  prefixIcon: const Icon(Icons.straighten),
                  border: const OutlineInputBorder(),
                  suffixText: 'km',
                ),
              ),
              const SizedBox(height: 32),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: miles == null
                    ? Text(
                        'Type a number to see the live conversion',
                        key: const ValueKey('hint'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      )
                    : Column(
                        key: const ValueKey('result'),
                        children: [
                          Text(
                            '${_format(km!)} km',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '=',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_format(miles)} miles',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
