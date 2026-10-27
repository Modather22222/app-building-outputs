import 'package:flutter/foundation.dart';

/// A single named counter and its current value.
@immutable
class NamedCounter {
  const NamedCounter({required this.id, required this.name, this.value = 0});

  final String id;
  final String name;
  final int value;

  NamedCounter copyWith({String? name, int? value}) => NamedCounter(
        id: id,
        name: name ?? this.name,
        value: value ?? this.value,
      );
}

/// In-memory state for the app: a list of named counters.
class CounterStackModel extends ChangeNotifier {
  CounterStackModel({List<NamedCounter>? counters})
      : _counters = List.of(counters ?? defaultCounters);

  static const List<NamedCounter> defaultCounters = [
    NamedCounter(id: 'coffee', name: 'Cups of coffee'),
    NamedCounter(id: 'pushups', name: 'Push-ups'),
    NamedCounter(id: 'pages', name: 'Pages read'),
  ];

  final List<NamedCounter> _counters;
  int _nextId = 0;

  List<NamedCounter> get counters => List.unmodifiable(_counters);

  int get total => _counters.fold(0, (sum, counter) => sum + counter.value);

  int _indexOf(String id) => _counters.indexWhere((c) => c.id == id);

  void increment(String id) {
    final int index = _indexOf(id);
    if (index == -1) return;
    _counters[index] = _counters[index].copyWith(
      value: _counters[index].value + 1,
    );
    notifyListeners();
  }

  void decrement(String id) {
    final int index = _indexOf(id);
    if (index == -1) return;
    final int next = _counters[index].value - 1;
    _counters[index] = _counters[index].copyWith(value: next < 0 ? 0 : next);
    notifyListeners();
  }

  void resetAll() {
    if (_counters.every((c) => c.value == 0)) return;
    for (int i = 0; i < _counters.length; i++) {
      _counters[i] = _counters[i].copyWith(value: 0);
    }
    notifyListeners();
  }

  void addCounter(String name) {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _counters.add(NamedCounter(id: 'counter-${_nextId++}', name: trimmed));
    notifyListeners();
  }

  void removeCounter(String id) {
    final int index = _indexOf(id);
    if (index == -1) return;
    _counters.removeAt(index);
    notifyListeners();
  }
}
