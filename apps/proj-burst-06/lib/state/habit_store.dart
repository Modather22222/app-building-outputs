import 'package:flutter/foundation.dart';

import '../models/habit.dart';

class HabitStore extends ChangeNotifier {
  HabitStore() {
    _seed();
  }

  final List<Habit> _habits = [];

  List<Habit> get habits => List.unmodifiable(_habits);

  void addHabit(String name, String emoji) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _habits.add(
      Habit(id: 'habit-${DateTime.now().microsecondsSinceEpoch}', name: trimmed, emoji: emoji),
    );
    notifyListeners();
  }

  void removeHabit(Habit habit) {
    _habits.remove(habit);
    notifyListeners();
  }

  void toggle(Habit habit, DateTime day) {
    habit.toggle(day);
    notifyListeners();
  }

  void _seed() {
    final today = Habit.dayOf(DateTime.now());
    DateTime daysAgo(int n) => today.subtract(Duration(days: n));

    final water = Habit(id: 'seed-water', name: 'Drink water', emoji: '💧');
    for (final i in [0, 1, 3, 4, 5, 6, 7, 8]) {
      water.completions.add(daysAgo(i));
    }

    final move = Habit(id: 'seed-move', name: 'Move 30 minutes', emoji: '🏃');
    for (final i in [0, 1, 2, 3, 4]) {
      move.completions.add(daysAgo(i));
    }

    final read = Habit(id: 'seed-read', name: 'Read 10 pages', emoji: '📖');
    for (final i in [1, 2, 3]) {
      read.completions.add(daysAgo(i));
    }

    _habits.addAll([water, move, read]);
  }
}
