import 'package:flutter/material.dart';

import 'units.dart';

/// One tab's converter: value input, from/to unit pickers and live result.
class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key, required this.category});

  final Category category;

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage>
    with AutomaticKeepAliveClientMixin {
  late final TextEditingController _valueController;
  late Unit _from;
  late Unit _to;

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController(text: '1');
    final units = widget.category.units;
    _from = units.first;
    _to = units.length > 1 ? units[1] : units.first;
    _valueController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  double? get _result {
    final value = double.tryParse(_valueController.text.trim());
    if (value == null) return null;
    return _from.convertTo(_to, value);
  }

  void _swap() {
    setState(() {
      final previous = _from;
      _from = _to;
      _to = previous;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final units = widget.category.units;
    final theme = Theme.of(context);
    final result = _result;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _valueController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Value',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(widget.category.icon),
                    errorText: result == null ? 'Enter a valid number' : null,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Unit>(
                        key: ValueKey(_from),
                        initialValue: _from,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'From',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (final unit in units)
                            DropdownMenuItem(value: unit, child: Text(unit.name)),
                        ],
                        onChanged: (unit) {
                          if (unit != null) setState(() => _from = unit);
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: _swap,
                      tooltip: 'Swap units',
                      icon: const Icon(Icons.swap_horiz),
                    ),
                    Expanded(
                      child: DropdownButtonFormField<Unit>(
                        key: ValueKey(_to),
                        initialValue: _to,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'To',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (final unit in units)
                            DropdownMenuItem(value: unit, child: Text(unit.name)),
                        ],
                        onChanged: (unit) {
                          if (unit != null) setState(() => _to = unit);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              Text(
                result == null ? '—' : formatResult(result),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                result == null ? '' : _to.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
