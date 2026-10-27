import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../state/expense_store.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({super.key, required this.store});

  final ExpenseStore store;

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  Category _category = Category.food;
  double? _amount;

  bool get _isValid => _amount != null && _amount! > 0;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String value) {
    setState(() => _amount = double.tryParse(value.replaceAll(',', '.')));
  }

  void _submit() {
    if (!_isValid) return;
    widget.store.addExpense(
      title: _titleController.text,
      amount: _amount!,
      category: _category,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add expense', style: textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: '0.00',
                prefixText: '\$ ',
              ),
              onChanged: _onAmountChanged,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'e.g. Coffee',
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final category in Category.values)
                  ChoiceChip(
                    avatar: Icon(category.icon, size: 16),
                    label: Text(category.label),
                    selected: _category == category,
                    onSelected: (_) =>
                        setState(() => _category = category),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isValid ? _submit : null,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Save expense'),
            ),
          ],
        ),
      ),
    );
  }
}
