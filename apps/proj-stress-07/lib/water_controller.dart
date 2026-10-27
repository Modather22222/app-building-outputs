import 'dart:async';

import 'package:flutter/foundation.dart';

class IntakeEntry {
  const IntakeEntry({required this.amountMl, required this.at});

  final int amountMl;
  final DateTime at;
}

/// Holds all in-memory state for the app: today's drinks, the daily goal,
/// and the hourly reminder toggle. Notifies listeners on every change.
class WaterController extends ChangeNotifier {
  WaterController() {
    _startReminderTimer();
  }

  static const List<int> quickAmounts = [100, 250, 500];

  final List<IntakeEntry> _entries = [];
  Timer? _reminderTimer;

  /// Called once per hour while [remindersEnabled] is true.
  VoidCallback? onReminder;

  int dailyGoalMl = 2000;
  bool remindersEnabled = true;

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  List<IntakeEntry> get todayEntries =>
      List<IntakeEntry>.unmodifiable(_entries.where((e) => _isToday(e.at)));

  int get todayTotalMl =>
      todayEntries.fold(0, (sum, e) => sum + e.amountMl);

  double get progress =>
      dailyGoalMl <= 0 ? 0.0 : (todayTotalMl / dailyGoalMl).clamp(0.0, 1.0);

  void addWater(int amountMl) {
    if (amountMl <= 0) return;
    _entries.add(IntakeEntry(amountMl: amountMl, at: DateTime.now()));
    notifyListeners();
  }

  void undoLast() {
    final today = todayEntries;
    if (today.isEmpty) return;
    _entries.remove(today.last);
    notifyListeners();
  }

  void resetDay() {
    _entries.removeWhere((e) => _isToday(e.at));
    notifyListeners();
  }

  void setGoal(int goalMl) {
    if (goalMl < 1000 || goalMl > 4000) return;
    dailyGoalMl = goalMl;
    notifyListeners();
  }

  void setRemindersEnabled(bool enabled) {
    remindersEnabled = enabled;
    notifyListeners();
  }

  void _startReminderTimer() {
    _reminderTimer?.cancel();
    _reminderTimer = Timer.periodic(const Duration(hours: 1), (_) {
      if (remindersEnabled) onReminder?.call();
    });
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    super.dispose();
  }
}
