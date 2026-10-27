import 'package:flutter/foundation.dart' hide Category;

import '../models/expense.dart';

/// In-memory store for all expenses. Persists nothing; the seed data makes the
/// UI meaningful on first launch.
class ExpenseStore extends ChangeNotifier {
  ExpenseStore() {
    _seed();
  }

  final List<Expense> _expenses = <Expense>[];
  int _nextId = 1;

  List<Expense> get expenses => List.unmodifiable(_expenses);

  double get monthTotal => _sumFor(_inCurrentMonth);

  int get monthCount => _expenses.where(_inCurrentMonth).length;

  double totalForDay(DateTime day) =>
      _sumFor((expense) => _isSameDay(expense.date, day));

  /// Totals for the last [days] days, oldest first (last entry is today).
  List<double> totalsForLastDays(int days) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      for (var i = days - 1; i >= 0; i--)
        totalForDay(today.subtract(Duration(days: i))),
    ];
  }

  void addExpense({
    required String title,
    required double amount,
    required Category category,
  }) {
    _expenses.add(Expense(
      id: 'e${_nextId++}',
      title: title.trim().isEmpty ? category.label : title.trim(),
      amount: amount,
      category: category,
      date: DateTime.now(),
    ));
    notifyListeners();
  }

  void removeExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
  }

  double _sumFor(bool Function(Expense) predicate) {
    var total = 0.0;
    for (final expense in _expenses) {
      if (predicate(expense)) total += expense.amount;
    }
    return total;
  }

  bool _inCurrentMonth(Expense expense) {
    final now = DateTime.now();
    return expense.date.year == now.year && expense.date.month == now.month;
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _seed() {
    void add(String title, double amount, Category category, DateTime date) {
      _expenses.add(Expense(
        id: 'e${_nextId++}',
        title: title,
        amount: amount,
        category: category,
        date: date,
      ));
    }

    final now = DateTime.now();
    DateTime daysAgo(int days, [int hour = 12]) {
      final day = now.subtract(Duration(days: days));
      return DateTime(day.year, day.month, day.day, hour);
    }

    add('Groceries', 42.50, Category.food, daysAgo(0, 9));
    add('Bus pass', 3.75, Category.transport, daysAgo(0, 8));
    add('Coffee & bagel', 7.20, Category.food, daysAgo(1, 10));
    add('Cinema tickets', 24.00, Category.fun, daysAgo(1, 20));
    add('Electricity bill', 61.30, Category.bills, daysAgo(3, 9));
    add('Running shoes', 89.99, Category.shopping, daysAgo(4, 17));
    add('Lunch with team', 18.40, Category.food, daysAgo(5, 13));
    add('Book store', 15.25, Category.shopping, daysAgo(8, 16));
    add('Taxi home', 12.00, Category.transport, daysAgo(10, 22));
    add('Streaming subscription', 9.99, Category.fun, daysAgo(15, 19));
  }
}
