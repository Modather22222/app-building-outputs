import 'dart:async';

import 'package:flutter/material.dart';

import 'note.dart';
import 'note_store.dart';

/// Create/edit screen. Edits auto-save (debounced while typing, flushed on
/// exit) so the user never has to press a save button.
class NoteEditorPage extends StatefulWidget {
  const NoteEditorPage({super.key, required this.store, this.existing});

  final NoteStore store;
  final Note? existing;

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  static const Duration _autosaveDelay = Duration(milliseconds: 600);

  late final Note _draft;
  late final TextEditingController _title;
  late final TextEditingController _body;
  Timer? _saveTimer;
  bool _dirty = false;
  bool _savedOnce = false;

  @override
  void initState() {
    super.initState();
    _draft = widget.existing ?? Note.create();
    _title = TextEditingController(text: _draft.title);
    _body = TextEditingController(text: _draft.body);
    _title.addListener(_onTextChanged);
    _body.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    if (_dirty) {
      final isEmpty = _title.text.trim().isEmpty && _body.text.trim().isEmpty;
      final shouldSave =
          widget.existing != null || _savedOnce || !isEmpty;
      if (shouldSave) {
        _draft
          ..title = _title.text
          ..body = _body.text;
        widget.store.upsert(_draft);
      }
    }
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() => _dirty = true);
    _saveTimer?.cancel();
    _saveTimer = Timer(_autosaveDelay, _saveNow);
  }

  void _saveNow() {
    _saveTimer?.cancel();
    _saveTimer = null;
    if (!_dirty) return;
    final isEmpty = _title.text.trim().isEmpty && _body.text.trim().isEmpty;
    if (widget.existing == null && !_savedOnce && isEmpty) return;
    _draft
      ..title = _title.text
      ..body = _body.text;
    widget.store.upsert(_draft);
    _savedOnce = true;
    setState(() => _dirty = false);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This note will be removed from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      widget.store.delete(_draft.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'New note' : 'Edit note'),
        actions: [
          if (widget.existing != null)
            IconButton(
              tooltip: 'Delete note',
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            TextField(
              controller: _title,
              style: theme.textTheme.titleLarge,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Title',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: InputBorder.none,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: TextField(
                controller: _body,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Start typing - changes save automatically.',
                  contentPadding: EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _dirty
                      ? 'Unsaved changes'
                      : (_savedOnce || widget.existing != null
                          ? 'Saved'
                          : ''),
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
