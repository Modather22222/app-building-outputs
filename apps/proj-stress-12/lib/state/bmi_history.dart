import 'package:flutter/foundation.dart';

import '../models/bmi_entry.dart';

/// In-memory history of BMI measurements.
///
/// Notifies listeners whenever an entry is added, removed or the list is
/// cleared. Data lives for the lifetime of the process only (no persistence).
class BmiHistory extends ChangeNotifier {
  final List<BmiEntry> _entries = <BmiEntry>[];

  /// Chronological (oldest first) snapshot of all measurements.
  List<BmiEntry> get entries => List<BmiEntry>.unmodifiable(_entries);

  bool get isEmpty => _entries.isEmpty;

  int get length => _entries.length;

  void add(BmiEntry entry) {
    _entries.add(entry);
    notifyListeners();
  }

  void remove(BmiEntry entry) {
    if (_entries.remove(entry)) {
      notifyListeners();
    }
  }

  void clear() {
    if (_entries.isEmpty) return;
    _entries.clear();
    notifyListeners();
  }
}
