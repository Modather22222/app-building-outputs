import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const TipSplitterApp());
}

class TipSplitterApp extends StatelessWidget {
  const TipSplitterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tip Splitter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.teal,
      ),
      themeMode: ThemeMode.system,
      home: const SplitterPage(),
    );
  }
}

class SplitterPage extends StatefulWidget {
  const SplitterPage({super.key});

  @override
  State<SplitterPage> createState() => _SplitterPageState();
}

class _SplitterPageState extends State<SplitterPage> {
  final TextEditingController _totalController = TextEditingController();
  int _people = 2;
  bool _roundUp = false;

  double get _total {
    final value = double.tryParse(_totalController.text.trim());
    return value == null || value < 0 ? 0 : value;
  }

  double get _perPerson {
    if (_people < 1 || _total <= 0) return 0;
    final share = _total / _people;
    return _roundUp
        ? share.ceilToDouble()
        : (share * 100).roundToDouble() / 100;
  }

  double get _grandTotal => _perPerson * _people;

  double get _overage => _grandTotal - _total;

  String _money(double value) => '\$${value.toStringAsFixed(2)}';

  @override
  void dispose() {
    _totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Tip Splitter')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _totalController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d{0,2}'),
                ),
              ],
              decoration: const InputDecoration(
                labelText: 'Bill total',
                prefixText: r'$ ',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Fewer people',
                      onPressed:
                          _people > 1 ? () => setState(() => _people--) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '$_people',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Text('people'),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'More people',
                      onPressed:
                          _people < 99 ? () => setState(() => _people++) : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ),
            ),
            SwitchListTile(
              title: const Text('Round up each share'),
              subtitle: const Text('Whole amounts per person'),
              value: _roundUp,
              onChanged: (value) => setState(() => _roundUp = value),
            ),
            const SizedBox(height: 12),
            Card(
              color: colors.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Each person pays',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _money(_perPerson),
                      key: const ValueKey('per-person'),
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _overage > 0.004
                          ? '${_money(_grandTotal)} collected, '
                              '${_money(_overage)} extra toward the bill'
                          : '${_money(_grandTotal)} total',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
