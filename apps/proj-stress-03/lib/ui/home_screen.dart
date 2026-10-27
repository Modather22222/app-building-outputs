import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../state/expense_store.dart';
import 'add_expense_sheet.dart';
import 'format.dart';
import 'week_bar_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.store});

  final ExpenseStore store;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Category? _filter;

  void _openAddSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => AddExpenseSheet(store: widget.store),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final store = widget.store;
        final visible = store.expenses
            .where((expense) =>
                _filter == null || expense.category == _filter)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        return Scaffold(
          appBar: AppBar(title: const Text('Expense Log')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openAddSheet,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add expense'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              _MonthTotalCard(
                total: store.monthTotal,
                count: store.monthCount,
              ),
              const SizedBox(height: 12),
              WeekBarChart(values: store.totalsForLastDays(7)),
              const SizedBox(height: 16),
              _buildFilterChips(),
              const SizedBox(height: 4),
              ..._buildExpenseGroups(visible),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('All'),
              selected: _filter == null,
              onSelected: (_) => setState(() => _filter = null),
            ),
          ),
          for (final category in Category.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                avatar: Icon(category.icon, size: 16),
                label: Text(category.label),
                selected: _filter == category,
                onSelected: (_) => setState(() => _filter = category),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildExpenseGroups(List<Expense> visible) {
    if (visible.isEmpty) {
      return [_EmptyState(filtered: _filter != null)];
    }
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final groups = <String, List<Expense>>{};
    for (final expense in visible) {
      final bucket = groups.putIfAbsent(dayLabel(expense.date, now), () => []);
      bucket.add(expense);
    }

    final widgets = <Widget>[];
    groups.forEach((label, items) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(
          label,
          style: textTheme.titleSmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ));
      for (final item in items) {
        widgets.add(_ExpenseTile(store: widget.store, expense: item));
      }
    });
    return widgets;
  }
}

class _MonthTotalCard extends StatelessWidget {
  const _MonthTotalCard({required this.total, required this.count});

  final double total;
  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${monthLabel(DateTime.now())} · $count ${count == 1 ? 'expense' : 'expenses'}',
              style:
                  textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              formatMoney(total),
              style: textTheme.displaySmall
                  ?.copyWith(fontWeight: FontWeight.w700, color: scheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({required this.store, required this.expense});

  final ExpenseStore store;
  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey<String>(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: scheme.errorContainer,
        child: Icon(Icons.delete_outline_rounded, color: scheme.onErrorContainer),
      ),
      onDismissed: (_) {
        final removed = expense;
        store.removeExpense(expense.id);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Removed "${removed.title}"')));
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          child: Icon(expense.category.icon, size: 20),
        ),
        title: Text(
          expense.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${expense.category.label} · '
          '${expense.date.hour.toString().padLeft(2, '0')}:'
          '${expense.date.minute.toString().padLeft(2, '0')}',
        ),
        trailing: Text(
          formatMoney(expense.amount),
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filtered});

  final bool filtered;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.receipt_long_rounded, size: 40, color: scheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            filtered ? 'No expenses in this category yet' : 'No expenses yet',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Tap "Add expense" to log your first one.',
            style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
