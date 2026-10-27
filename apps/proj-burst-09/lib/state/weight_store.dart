import 'dart:math';

import 'package:flutter/foundation.dart';

import '../util/ui.dart';

class WeightEntry {
  const WeightEntry(this.date, this.weight);

  final DateTime date;
  final double weight;
}

class WeightStore extends ChangeNotifier {
  WeightStore() {
    _seed();
  }

  final List<WeightEntry> _entries = [];

  List<WeightEntry> get entries => List.unmodifiable(_entries);

  WeightEntry? get latest => _entries.isEmpty ? null : _entries.last;

  void upsert(DateTime day, double weight) {
    final d = dayOf(day);
    final i = _entries.indexWhere((e) => e.date == d);
    if (i >= 0) {
      _entries[i] = WeightEntry(d, weight);
    } else {
      _entries.add(WeightEntry(d, weight));
      _entries.sort((a, b) => a.date.compareTo(b.date));
    }
    notifyListeners();
  }

  void remove(DateTime day) {
    final d = dayOf(day);
    _entries.removeWhere((e) => e.date == d);
    notifyListeners();
  }

  void _seed() {
    final random = Random(7);
    final today = dayOf(DateTime.now());
    for (var daysAgo = 20; daysAgo >= 0; daysAgo--) {
      if (daysAgo % 6 == 2 && daysAgo != 0) continue;
      final drift = -0.14 * (20 - daysAgo);
      final noise = (random.nextDouble() - 0.5) * 0.8;
      final kg = ((76.4 + drift + noise) * 10).roundToDouble() / 10;
      upsert(today.subtract(Duration(days: daysAgo)), kg);
    }
  }
}
