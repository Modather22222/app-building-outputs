import 'package:flutter/material.dart';

import 'notes_store.dart';

void main() {
  runApp(const QuickNotesApp());
}

class QuickNotesApp extends StatelessWidget {
  const QuickNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Notes',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo, brightness: Brightness.dark),
      home: const NotesHomePage(),
    );
  }
}

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key});

  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  final NotesStore _store = NotesStore();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _cardColor(BuildContext context, Note note) {
    if (note.colorIndex < 0) return Theme.of(context).colorScheme.surfaceContainer;
    final base = noteColors[note.colorIndex];
    return Color.alphaBlend(
      base.withValues(alpha: 0.35),
      Theme.of(context).colorScheme.surfaceContainer,
    );
  }

  Future<void> _openEditor([Note? note]) async {
    final saved = await Navigator.of(context).push<Note>(
      MaterialPageRoute(builder: (_) => NoteEditorPage(existing: note)),
    );
    if (saved == null) return;
    setState(() {
      if (note == null) {
        _store.add(title: saved.title, body: saved.body, colorIndex: saved.colorIndex);
      } else {
        _store.update(
          note.id,
          title: saved.title,
          body: saved.body,
          colorIndex: saved.colorIndex,
          pinned: note.pinned,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notes = _store.notes;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Notes'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('${notes.length} notes')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('New note'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _store.setQuery(value)),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search notes…',
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _store.setQuery(''));
                        },
                      ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: notes.isEmpty
                ? Center(
                    child: Text(
                      _store.query.isEmpty
                          ? 'No notes yet — tap "New note".'
                          : 'No notes match "${_store.query}".',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    itemCount: notes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return _NoteCard(
                        note: note,
                        color: _cardColor(context, note),
                        onOpen: () => _openEditor(note),
                        onTogglePin: () => setState(() => _store.togglePin(note.id)),
                        onCycleColor: () => setState(() => _store.cycleColor(note.id)),
                        onDelete: () {
                          setState(() => _store.delete(note.id));
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(content: Text('Deleted "${note.title}"')),
                            );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.color,
    required this.onOpen,
    required this.onTogglePin,
    required this.onCycleColor,
    required this.onDelete,
  });

  final Note note;
  final Color color;
  final VoidCallback onOpen;
  final VoidCallback onTogglePin;
  final VoidCallback onCycleColor;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: 1,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (note.pinned) ...[
                    Icon(Icons.push_pin, size: 16, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: note.pinned ? 'Unpin' : 'Pin',
                    icon: Icon(
                      note.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                      size: 20,
                    ),
                    onPressed: onTogglePin,
                  ),
                  IconButton(
                    tooltip: 'Change label color',
                    icon: const Icon(Icons.label_outline, size: 20),
                    onPressed: onCycleColor,
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onDelete,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  note.body.isEmpty ? '(empty)' : note.body,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoteEditorPage extends StatefulWidget {
  const NoteEditorPage({super.key, this.existing});

  final Note? existing;

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late final TextEditingController _title =
      TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _body =
      TextEditingController(text: widget.existing?.body ?? '');
  late int _colorIndex = widget.existing?.colorIndex ?? -1;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _save() {
    final title = _title.text.trim().isEmpty ? 'Untitled' : _title.text.trim();
    Navigator.of(context).pop(Note(
      id: widget.existing?.id ?? 0,
      title: title,
      body: _body.text.trim(),
      updatedAt: DateTime.now(),
      colorIndex: _colorIndex,
      pinned: widget.existing?.pinned ?? false,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'New note' : 'Edit note'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _title,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _body,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            Text('Label color', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _colorChoice(-1, Theme.of(context).colorScheme.surfaceContainer),
                for (var i = 0; i < noteColors.length; i++) _colorChoice(i, noteColors[i]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorChoice(int index, Color color) {
    final selected = _colorIndex == index;
    return ChoiceChip(
      label: index < 0 ? const Text('None') : const SizedBox(width: 32),
      selected: selected,
      selectedColor: color,
      backgroundColor: color,
      showCheckmark: false,
      side: selected
          ? BorderSide(width: 2, color: Theme.of(context).colorScheme.primary)
          : null,
      onSelected: (_) => setState(() => _colorIndex = index),
    );
  }
}
