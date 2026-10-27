import 'package:flutter/material.dart';

void main() => runApp(const GroceryCheckApp());

class GroceryItem {
  GroceryItem({required this.name, required this.quantity, this.done = false});

  final String name;
  int quantity;
  bool done;
}

class GroceryList {
  final List<GroceryItem> _items = [];

  List<GroceryItem> get items => List.unmodifiable(_items);
  int get doneCount => _items.where((i) => i.done).length;

  void add(String name, int quantity) {
    _items.add(GroceryItem(name: name.trim(), quantity: quantity > 0 ? quantity : 1));
  }

  void toggle(GroceryItem item) {
    item.done = !item.done;
  }

  void changeQuantity(GroceryItem item, int delta) {
    item.quantity = (item.quantity + delta).clamp(1, 99);
  }

  void remove(GroceryItem item) {
    _items.remove(item);
  }

  void clearDone() {
    _items.removeWhere((i) => i.done);
  }
}

class GroceryCheckApp extends StatelessWidget {
  const GroceryCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Grocery Check',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
        darkTheme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green, brightness: Brightness.dark),
        themeMode: ThemeMode.system,
        home: const ChecklistScreen(),
    );
  }
}

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final GroceryList _list = GroceryList();
  final TextEditingController _nameController = TextEditingController();
  int _quantity = 1;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addItem() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter an item name first'), duration: Duration(seconds: 1)),
      );
      return;
    }
    setState(() {
      _list.add(name, _quantity);
      _nameController.clear();
      _quantity = 1;
    });
  }

  void _changeQuantity(GroceryItem item, int delta) {
    setState(() => _list.changeQuantity(item, delta));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final items = _list.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery Check'),
        actions: [
          if (_list.doneCount > 0)
            IconButton(
              tooltip: 'Clear done items',
              icon: const Icon(Icons.cleaning_services_outlined),
              onPressed: () => setState(_list.clearDone),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addItem(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Add an item',
                      hintText: 'e.g. Bananas',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 1, label: Text('1')),
                    ButtonSegment(value: 2, label: Text('2')),
                    ButtonSegment(value: 5, label: Text('5')),
                  ],
                  selected: {_quantity},
                  onSelectionChanged: (s) => setState(() => _quantity = s.first),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.outlineVariant),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 64, color: colors.outline),
                        const SizedBox(height: 8),
                        Text('Your list is empty', style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 4),
                        Text('Add your first grocery item above',
                            style: TextStyle(color: colors.outline)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: Checkbox(
                            value: item.done,
                            onChanged: (_) => setState(() => _list.toggle(item)),
                          ),
                          title: Text(
                            item.name,
                            style: TextStyle(
                              decoration: item.done ? TextDecoration.lineThrough : null,
                              color: item.done ? colors.outline : colors.onSurface,
                            ),
                          ),
                          subtitle: Text('${item.done ? 'Done' : 'Todo'} • qty ${item.quantity}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Decrease quantity',
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => _changeQuantity(item, -1),
                              ),
                              Text('${item.quantity}',
                                  style: Theme.of(context).textTheme.titleMedium),
                              IconButton(
                                tooltip: 'Increase quantity',
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => _changeQuantity(item, 1),
                              ),
                              IconButton(
                                tooltip: 'Delete item',
                                icon: Icon(Icons.delete_outline, color: colors.error),
                                onPressed: () => setState(() => _list.remove(item)),
                              ),
                            ],
                          ),
                          onLongPress: () => setState(() => _list.remove(item)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text('${_list.doneCount} of ${_list.items.length} done'),
              const Spacer(),
              Text('🛒 ${_list.items.length} items'),
            ],
          ),
        ),
      ),
    );
  }
}
