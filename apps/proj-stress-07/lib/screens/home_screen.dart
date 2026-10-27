import 'package:flutter/material.dart';

import '../water_controller.dart';
import '../widgets/goal_ring.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WaterController _controller = WaterController();

  @override
  void initState() {
    super.initState();
    _controller.onReminder = _showReminder;
  }

  @override
  void dispose() {
    _controller.onReminder = null;
    _controller.dispose();
    super.dispose();
  }

  void _showReminder() {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Time to drink some water 💧'),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
      ),
    );
  }

  Future<void> _editGoal() async {
    final newGoal = await showDialog<int>(
      context: context,
      builder: (_) => _GoalDialog(current: _controller.dailyGoalMl),
    );
    if (newGoal != null) _controller.setGoal(newGoal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Reminder'),
        actions: [
          IconButton(
            tooltip: 'Edit daily goal',
            icon: const Icon(Icons.flag_outlined),
            onPressed: _editGoal,
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final entries = _controller.todayEntries;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: GoalRing(
                    progress: _controller.progress,
                    currentMl: _controller.todayTotalMl,
                    goalMl: _controller.dailyGoalMl,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final amount in WaterController.quickAmounts)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: FilledButton.tonal(
                          onPressed: () => _controller.addWater(amount),
                          child: Text('+$amount ml'),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed:
                          entries.isEmpty ? null : _controller.undoLast,
                      icon: const Icon(Icons.undo),
                      label: const Text('Undo'),
                    ),
                    const SizedBox(width: 24),
                    TextButton.icon(
                      onPressed: _controller.todayTotalMl == 0
                          ? null
                          : _controller.resetDay,
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Reset day'),
                    ),
                  ],
                ),
                SwitchListTile(
                  title: const Text('Hourly reminders'),
                  subtitle: const Text(
                    'Nudge me once per hour while the app is open',
                  ),
                  value: _controller.remindersEnabled,
                  onChanged: _controller.setRemindersEnabled,
                ),
                const Divider(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    "Today's log",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  child: entries.isEmpty
                      ? const Center(
                          child: Text('No drinks logged yet today 💧'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final entry =
                                entries[entries.length - 1 - index];
                            return ListTile(
                              leading: const Icon(Icons.water_drop),
                              title: Text('${entry.amountMl} ml'),
                              trailing: Text(
                                TimeOfDay.fromDateTime(entry.at)
                                    .format(context),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GoalDialog extends StatefulWidget {
  const _GoalDialog({required this.current});

  final int current;

  @override
  State<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<_GoalDialog> {
  late int _value = widget.current;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Daily goal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$_value ml', style: Theme.of(context).textTheme.titleLarge),
          Slider(
            min: 1000,
            max: 4000,
            divisions: 12,
            value: _value.toDouble(),
            label: '$_value ml',
            onChanged: (v) =>
                setState(() => _value = (v / 250).round() * 250),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _value),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
