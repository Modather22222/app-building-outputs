import 'package:flutter/material.dart';

import 'counter_stack_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CounterStackModel _model = CounterStackModel();

  @override
  void initState() {
    super.initState();
    _model.addListener(_onModelChanged);
  }

  void _onModelChanged() => setState(() {});

  @override
  void dispose() {
    _model.removeListener(_onModelChanged);
    _model.dispose();
    super.dispose();
  }

  Future<void> _confirmResetAll() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Reset all counters?'),
        content: const Text('Every counter will go back to zero.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      _model.resetAll();
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('All counters reset')));
      }
    }
  }

  Future<void> _addCounter() async {
    final TextEditingController nameController = TextEditingController();
    final String? name = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('New counter'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Counter name',
            hintText: 'e.g. Glasses of water',
          ),
          onSubmitted: (String value) => Navigator.of(context).pop(value),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(nameController.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    nameController.dispose();
    if (name != null) _model.addCounter(name);
  }

  @override
  Widget build(BuildContext context) {
    final List<NamedCounter> counters = _model.counters;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Stack'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Reset all counters',
            onPressed: counters.isEmpty ? null : _confirmResetAll,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          if (counters.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Total: ${_model.total}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
          Expanded(
            child: counters.isEmpty
                ? const Center(
                    child: Text('No counters yet. Tap the button to add one.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: counters.length,
                    itemBuilder: (BuildContext context, int index) {
                      final NamedCounter counter = counters[index];
                      return _CounterCard(
                        counter: counter,
                        onIncrement: () => _model.increment(counter.id),
                        onDecrement: () => _model.decrement(counter.id),
                        onRemove: () => _model.removeCounter(counter.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCounter,
        icon: const Icon(Icons.add),
        label: const Text('New counter'),
      ),
    );
  }
}

class _CounterCard extends StatelessWidget {
  const _CounterCard({
    required this.counter,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final NamedCounter counter;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    counter.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${counter.value}',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: colors.primary),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Remove counter',
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
            ),
            IconButton(
              tooltip: 'Minus',
              onPressed: onDecrement,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            IconButton.filledTonal(
              tooltip: 'Plus',
              onPressed: onIncrement,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
