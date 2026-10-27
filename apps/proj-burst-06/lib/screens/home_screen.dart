import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../state/habit_store.dart';

const emojiChoices = ['💧', '🏃', '📖', '🧘', '💪', '🌙', '🥗', '✍️'];
const _leadingWidth = 116.0;
const _trailingWidth = 36.0;

DateTime startOfWeek(DateTime now) {
  final today = Habit.dayOf(now);
  return today.subtract(Duration(days: today.weekday - 1));
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.store});

  final HabitStore store;

  @override
  Widget build(BuildContext context) {
    final weekStart = startOfWeek(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Habit Grid')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add habit'),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          if (store.habits.isEmpty) {
            return const _EmptyState();
          }
          return ListView(
            key: const ValueKey('habit-grid-list'),
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
            children: [
              _GridHeader(weekStart: weekStart),
              for (final habit in store.habits)
                _HabitRow(
                  habit: habit,
                  weekStart: weekStart,
                  store: store,
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showAddHabitSheet(BuildContext context) {
    final controller = TextEditingController();
    var emoji = emojiChoices.first;

    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('New habit'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    maxLength: 24,
                    decoration: const InputDecoration(
                      labelText: 'Habit name',
                      hintText: 'e.g. Meditate',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      for (final choice in emojiChoices)
                        ChoiceChip(
                          label: Text(choice),
                          selected: emoji == choice,
                          onSelected: (_) => setDialogState(() => emoji = choice),
                        ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    store.addHabit(controller.text, emoji);
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.grid_on_outlined, size: 56, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          const Text('No habits yet'),
          const SizedBox(height: 4),
          const Text('Tap "Add habit" to build your first grid.'),
        ],
      ),
    );
  }
}

class _GridHeader extends StatelessWidget {
  const _GridHeader({required this.weekStart});

  final DateTime weekStart;

  @override
  Widget build(BuildContext context) {
    const letters = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    final today = Habit.dayOf(DateTime.now());

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const SizedBox(
            width: _leadingWidth,
            child: Text('This week', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Column(
                children: [
                  Text(letters[i], style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    '${weekStart.add(Duration(days: i)).day}',
                    style: TextStyle(
                      fontSize: 10,
                      color: weekStart.add(Duration(days: i)) == today
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: _trailingWidth),
        ],
      ),
    );
  }
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({required this.habit, required this.weekStart, required this.store});

  final Habit habit;
  final DateTime weekStart;
  final HabitStore store;

  @override
  Widget build(BuildContext context) {
    final today = Habit.dayOf(DateTime.now());
    final streak = habit.streak;

    return Row(
      children: [
        SizedBox(
          width: _leadingWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${habit.emoji} ${habit.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                streak > 0 ? '🔥 $streak day streak' : 'No streak yet',
                style: TextStyle(
                  fontSize: 11,
                  color: streak > 0
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        for (var i = 0; i < 7; i++)
          Expanded(
            child: _DayCell(
              valueKey: ValueKey('cell-${habit.id}-${weekStart.add(Duration(days: i)).toIso8601String()}'),
              habit: habit,
              day: weekStart.add(Duration(days: i)),
              isToday: weekStart.add(Duration(days: i)) == today,
              enabled: !weekStart.add(Duration(days: i)).isAfter(today),
              onToggle: () => store.toggle(habit, weekStart.add(Duration(days: i))),
            ),
          ),
        SizedBox(
          width: _trailingWidth,
          child: PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            iconSize: 20,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
            onSelected: (action) {
              if (action == 'delete') store.removeHabit(habit);
            },
          ),
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.valueKey,
    required this.habit,
    required this.day,
    required this.isToday,
    required this.enabled,
    required this.onToggle,
  });

  final Key valueKey;
  final Habit habit;
  final DateTime day;
  final bool isToday;
  final bool enabled;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final done = habit.isDone(day);
    final colors = Theme.of(context).colorScheme;

    return Padding(
      key: valueKey,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: GestureDetector(
        onTap: enabled ? onToggle : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 38,
          decoration: BoxDecoration(
            color: done ? colors.primary : colors.surface,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: done
                  ? colors.primary
                  : isToday
                      ? colors.primary
                      : colors.outlineVariant,
              width: isToday && !done ? 1.6 : 1,
            ),
          ),
          child: done
              ? Icon(Icons.check_rounded, size: 18, color: colors.onPrimary)
              : null,
        ),
      ),
    );
  }
}
