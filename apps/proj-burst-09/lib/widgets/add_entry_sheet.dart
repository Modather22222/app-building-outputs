import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/weight_store.dart';
import '../util/ui.dart';

Future<void> showAddEntrySheet(BuildContext context, WeightStore store) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: _AddEntryForm(store: store),
    ),
  );
}

class _AddEntryForm extends StatefulWidget {
  const _AddEntryForm({required this.store});

  final WeightStore store;

  @override
  State<_AddEntryForm> createState() => _AddEntryFormState();
}

class _AddEntryFormState extends State<_AddEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  DateTime _date = dayOf(DateTime.now());

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = dayOf(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(today) ? today : _date,
      firstDate: DateTime(2000),
      lastDate: today,
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  void _save() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    final kg = double.parse(_weightController.text.replaceAll(',', '.'));
    widget.store.upsert(_date, kg);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.store.entries.any((e) => e.date == _date);
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Log weight', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.event_outlined),
              const SizedBox(width: 12),
              Text(
                formatDay(_date),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              TextButton(onPressed: _pickDate, child: const Text('Change')),
            ],
          ),
          TextFormField(
            controller: _weightController,
            decoration: const InputDecoration(
              labelText: 'Weight (kg)',
              hintText: 'e.g. 72.5',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*[.,]?[0-9]*$')),
            ],
            autofocus: true,
            validator: (value) {
              final kg = double.tryParse(value?.replaceAll(',', '.') ?? '');
              if (kg == null || kg <= 0 || kg > 500) {
                return 'Enter a weight between 1 and 500 kg';
              }
              return null;
            },
            onFieldSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: Text(existing ? 'Update entry' : 'Add entry'),
          ),
        ],
      ),
    );
  }
}
