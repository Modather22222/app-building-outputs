import 'package:flutter/material.dart';

void main() {
  runApp(const TipSplitterApp());
}

class SplitterModel extends ChangeNotifier {
  double _amount = 0;
  int _people = 2;
  bool _roundUp = false;

  static const int _minPeople = 1;
  static const int _maxPeople = 20;

  double get amount => _amount;
  int get people => _people;
  bool get roundUp => _roundUp;

  double get rawShare => _people > 0 ? _amount / _people : 0;

  int get perPerson {
    if (_roundUp) return _amount > 0 ? rawShare.ceil() : 0;
    return 0;
  }

  double get sharePerPerson {
    if (_roundUp) return perPerson.toDouble();
    return rawShare;
  }

  double get collectedTotal {
    if (_roundUp) return (perPerson * _people).toDouble();
    return _amount;
  }

  double get extraTotal => collectedTotal - _amount;

  bool get canAddPeople => _people < _maxPeople;
  bool get canRemovePeople => _people > _minPeople;

  void setAmount(double value) {
    _amount = value.isNaN || value < 0 ? 0 : value;
    notifyListeners();
  }

  void incrementPeople() {
    if (canAddPeople) {
      _people++;
      notifyListeners();
    }
  }

  void decrementPeople() {
    if (canRemovePeople) {
      _people--;
      notifyListeners();
    }
  }

  void toggleRoundUp(bool value) {
    _roundUp = value;
    notifyListeners();
  }
}

class TipSplitterApp extends StatelessWidget {
  const TipSplitterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tip Splitter',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const SplitterScreen(),
    );
  }
}

class SplitterScreen extends StatefulWidget {
  const SplitterScreen({super.key});

  @override
  State<SplitterScreen> createState() => _SplitterScreenState();
}

class _SplitterScreenState extends State<SplitterScreen> {
  final SplitterModel _model = SplitterModel();
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _model.dispose();
    super.dispose();
  }

  void _onAmountChanged(String text) {
    final value = double.tryParse(text.replaceAll(',', '.')) ?? 0;
    _model.setAmount(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tip Splitter')),
      body: ListenableBuilder(
        listenable: _model,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Total amount',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                onChanged: _onAmountChanged,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('People', style: TextStyle(fontSize: 16)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _model.canRemovePeople
                        ? _model.decrementPeople
                        : null,
                  ),
                  Text('${_model.people}', style: const TextStyle(fontSize: 20)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _model.canAddPeople ? _model.incrementPeople : null,
                  ),
                ],
              ),
              SwitchListTile(
                title: const Text('Round up each share'),
                subtitle: const Text('Round each person\'s share up to the next dollar'),
                value: _model.roundUp,
                onChanged: _model.toggleRoundUp,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              _ResultCard(model: _model),
            ],
          );
        },
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.model});

  final SplitterModel model;

  String _format(double value) => '\$${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final share = model.sharePerPerson;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Per person', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              share > 0 ? _format(share) : '—',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Collected total'),
                Text(_format(model.collectedTotal)),
              ],
            ),
            if (model.roundUp && model.extraTotal > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Extra from rounding'),
                  Text(_format(model.extraTotal)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
