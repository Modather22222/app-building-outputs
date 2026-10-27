import 'package:flutter/material.dart';

import 'state/weight_store.dart';
import 'util/ui.dart';
import 'widgets/add_entry_sheet.dart';
import 'widgets/trend_chart.dart';
import 'widgets/weight_list.dart';

void main() {
  runApp(const WeightLogApp());
}

class WeightLogApp extends StatelessWidget {
  const WeightLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weight Log',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeightStore _store = WeightStore();

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weight Log'), centerTitle: false),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddEntrySheet(context, _store),
        icon: const Icon(Icons.add),
        label: const Text('Log weight'),
      ),
      body: ListenableBuilder(
        listenable: _store,
        builder: (context, _) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _SummaryCards(store: _store)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                      child: TrendChart(entries: _store.entries),
                    ),
                  ),
                ),
              ),
              WeightListSliver(store: _store),
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.store});

  final WeightStore store;

  @override
  Widget build(BuildContext context) {
    final entries = store.entries;
    if (entries.isEmpty) return const SizedBox.shrink();
    final latest = entries.last;
    final cutoff = latest.date.subtract(const Duration(days: 7));
    WeightEntry? baseline;
    for (final entry in entries) {
      if (entry.date.isAfter(cutoff)) break;
      baseline = entry;
    }
    if (baseline == null || baseline.date == latest.date) {
      baseline = entries.length > 1 ? entries[entries.length - 2] : null;
    }
    double? diff;
    String? since;
    if (baseline != null && baseline.date != latest.date) {
      diff = latest.weight - baseline.weight;
      since = formatDay(baseline.date);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'Current',
              value: formatWeight(latest.weight),
              icon: Icons.monitor_weight_outlined,
            ),
          ),
          if (diff != null && since != null) ...[
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'since $since',
                value: '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)} kg',
                icon: diff < 0
                    ? Icons.trending_down
                    : diff > 0
                        ? Icons.trending_up
                        : Icons.trending_flat,
                valueColor: deltaColor(diff, Theme.of(context).brightness),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: scheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? scheme.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
