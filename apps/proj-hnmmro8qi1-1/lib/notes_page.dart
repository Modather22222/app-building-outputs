import 'package:flutter/material.dart';

import 'note.dart';
import 'note_editor_page.dart';
import 'note_store.dart';

/// Home screen: searchable list of notes with delete + undo.
class NotesPage extends StatefulWidget {
  const NotesPage({super.key, required this.store});

  final NoteStore store;

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QuickNote')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.post_add_outlined),
        label: const Text('New note'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search notes',
                  isDense: true,
                  border: const OutlineInputBorder(),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: 'Clear search',
                          onPressed: () => setState(() => _query = ''),
                        ),
                ),
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.store,
                builder: (context, _) {
                  if (!widget.store.loaded) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final visible = _visibleNotes();
                  if (visible.isEmpty) {
                    return _EmptyState(query: _query);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 96),
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final note = visible[index];
                      return _NoteCard(
                        key: ValueKey<String>(note.id),
                        note: note,
                        onOpen: () => _openEditor(existing: note),
                        onDismissed: () => _deleteNote(note),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Note> _visibleNotes() {
    final notes = widget.store.notes;
    if (_query.trim().isEmpty) return notes;
    return notes.where((note) => note.matches(_query)).toList();
  }

  Future<void> _openEditor({Note? existing}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NoteEditorPage(store: widget.store, existing: existing),
      ),
    );
  }

  void _deleteNote(Note note) {
    final removed = widget.store.delete(note.id);
    if (removed == null) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Note deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => widget.store.restore(removed),
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    super.key,
    required this.note,
    required this.onOpen,
    required this.onDismissed,
  });

  final Note note;
  final VoidCallback onOpen;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = note.body.trim().replaceAll('\n', ' ');
    return Dismissible(
      key: ValueKey<String>('dismiss-${note.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        color: theme.colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Icon(
          Icons.delete_outline,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          onTap: onOpen,
          title: Text(
            note.title.trim().isEmpty ? 'Untitled' : note.title.trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            preview.isEmpty ? 'No content' : preview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            _formatDate(note.updatedAt),
            style: theme.textTheme.labelSmall,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searching = query.trim().isNotEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sticky_note_2_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            searching ? 'No matching notes' : 'No notes yet',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            searching
                ? 'Try a different search term.'
                : 'Tap "New note" to capture your first thought.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}
