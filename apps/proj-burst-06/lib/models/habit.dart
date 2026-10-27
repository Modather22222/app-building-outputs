import 'package:flutter/foundation.dart';

@immutable
class Habit {
  Habit({required this.id, required this.name, required this.emoji});

  final String id;
  final String name;
  final String emoji;

  final Set<DateTime> completions = {};

  bool isDone(DateTime day) {
    final normalized = dayOf(day);
    return completions.contains(normalized);
  }

  void toggle(DateTime day) {
    final normalized = dayOf(day);
    if (!completions.remove(normalized)) {
      completions.add(normalized);
    }
  }

  int get streak {
    var count = 0;
    var cursor = dayOf(DateTime.now());
    if (!isDone(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    while (isDone(cursor)) {
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }

  static DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);
}
