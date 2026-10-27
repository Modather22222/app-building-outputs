import 'package:flutter/material.dart';

import '../state/weight_store.dart';
import '../util/ui.dart';

class WeightListSliver extends StatelessWidget {
  const WeightListSliver({super.key, required this.store});

  final WeightStore store;

  @override
  Widget build(BuildContext context) {
    final entries = store.entries;
    if (entries.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: Text('No entries yet — log your first weight!')),
        ),
      );
    }
    return SliverList.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final i = entries.length - 1 - index;
        final entry = entries[i];
        final previous = i > 0 ? entries[i - 1] : null;
        final delta = previous == null ? null : entry.weight - previous.weight;
        final scheme = Theme.of(context).colorScheme;
        return Dismissible(
          key: ValueKey(entry.date.millisecondsSinceEpoch),
          direction: DismissDirection.endToStart,
          background: Container(
            color: scheme.errorContainer,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
          ),
          onDismissed: (_) {
            store.remove(entry.date);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('Entry for ${formatDay(entry.date)} removed'),
                ),
              );
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: scheme.secondaryContainer,
              foregroundColor: scheme.onSecondaryContainer,
              child: Icon(
                delta == null || delta == 0
                    ? Icons.trending_flat
                    : delta < 0
                        ? Icons.trending_down
                        : Icons.trending_up,
              ),
            ),
            title: Text(formatWeight(entry.weight)),
            subtitle: Text(formatDay(entry.date)),
            trailing: delta == null || delta == 0
                ? null
                : Text(
                    '${delta.toStringAsFixed(1)} kg',
                    style: TextStyle(
                      color: deltaColor(delta, Theme.of(context).brightness),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
