import 'package:flutter/material.dart';

import '../models/bmi_entry.dart';
import '../state/bmi_history.dart';
import '../widgets/bmi_chart.dart';

/// Main screen: input, result card with healthy-range guidance, and the
/// history chart/list, all driven by the [BmiHistory] ChangeNotifier.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.history});

  final BmiHistory history;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  BmiEntry? _latest;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _calculate() {
    final double? height =
        double.tryParse(_heightController.text.trim().replaceAll(',', '.'));
    final double? weight =
        double.tryParse(_weightController.text.trim().replaceAll(',', '.'));

    if (height == null ||
        weight == null ||
        height < 50 ||
        height > 250 ||
        weight < 10 ||
        weight > 400) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Enter height in cm (50-250) and weight in kg (10-400).'),
        ));
      return;
    }

    setState(() {
      _latest = BmiEntry(timestamp: DateTime.now(), heightCm: height, weightKg: weight);
    });
    widget.history.add(_latest!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Coach'),
        actions: <Widget>[
          ListenableBuilder(
            listenable: widget.history,
            builder: (BuildContext context, Widget? child) {
              if (widget.history.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Clear history',
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: widget.history.clear,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildInputCard(),
              if (_latest != null) ...<Widget>[
                const SizedBox(height: 16),
                _ResultCard(entry: _latest!),
              ],
              const SizedBox(height: 16),
              ListenableBuilder(
                listenable: widget.history,
                builder: (BuildContext context, Widget? child) {
                  return _HistoryCard(
                    entries: widget.history.entries,
                    onRemove: widget.history.remove,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Measurements', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Metric units: height in centimeters, weight in kilograms.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('height-field'),
              controller: _heightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Height (cm)',
                hintText: 'e.g. 175',
                prefixIcon: Icon(Icons.height),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('weight-field'),
              controller: _weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                hintText: 'e.g. 70',
                prefixIcon: Icon(Icons.monitor_weight_outlined),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _calculate(),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('Calculate BMI'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.entry});

  final BmiEntry entry;

  @override
  Widget build(BuildContext context) {
    final BmiCategory category = entry.category;
    final double min = entry.healthyMinWeightKg;
    final double max = entry.healthyMaxWeightKg;

    final String position;
    if (entry.weightKg < min) {
      position =
          'That is ${(min - entry.weightKg).toStringAsFixed(1)} kg below the healthy range for your height.';
    } else if (entry.weightKg > max) {
      position =
          'That is ${(entry.weightKg - max).toStringAsFixed(1)} kg above the healthy range for your height.';
    } else {
      position = 'That is inside the healthy range for your height.';
    }

    return Card(
      color: category.color.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'YOUR BMI',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                Text(
                  entry.bmi.toStringAsFixed(1),
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Chip(
                  visualDensity: VisualDensity.compact,
                  avatar: Icon(Icons.circle, size: 12, color: category.color),
                  label: Text(category.label),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Healthy weight for ${entry.heightCm.toStringAsFixed(0)} cm: '
              '${min.toStringAsFixed(1)}-${max.toStringAsFixed(1)} kg',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '$position ${category.advice}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entries, required this.onRemove});

  final List<BmiEntry> entries;
  final void Function(BmiEntry) onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('History', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: <Widget>[
                    Icon(Icons.show_chart,
                        size: 40, color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 8),
                    Text(
                      'Calculate your BMI to start your history.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              )
            else ...<Widget>[
              BmiChart(entries: entries),
              const SizedBox(height: 12),
              Text(
                '${entries.length} measurement${entries.length == 1 ? '' : 's'} '
                '(oldest first in chart) - tap the bin to delete.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              for (final BmiEntry entry in entries.reversed)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.circle,
                      size: 12, color: entry.category.color),
                  title: Text('${entry.bmi.toStringAsFixed(1)} - ${entry.category.label}'),
                  subtitle: Text(
                    '${entry.weightKg.toStringAsFixed(1)} kg at '
                    '${entry.heightCm.toStringAsFixed(0)} cm - ${_format(entry.timestamp)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete entry',
                    onPressed: () => onRemove(entry),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _format(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
