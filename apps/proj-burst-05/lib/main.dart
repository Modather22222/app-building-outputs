import 'package:flutter/material.dart';

void main() {
  runApp(const WordCountApp());
}

class WordCountApp extends StatelessWidget {
  const WordCountApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Count',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: const CounterPage(),
    );
  }
}

class TextStats {
  const TextStats({
    required this.text,
    required this.words,
    required this.characters,
    required this.charactersNoSpaces,
    required this.lines,
  });

  final String text;
  final int words;
  final int characters;
  final int charactersNoSpaces;
  final int lines;

  static TextStats of(String text) {
    final trimmed = text.trim();
    final words = trimmed.isEmpty
        ? 0
        : trimmed.split(RegExp(r'\s+')).length;
    final characters = text.length;
    final charactersNoSpaces = text.replaceAll(RegExp(r'\s'), '').length;
    final lines = text.isEmpty ? 0 : text.split('\n').length;
    return TextStats(
      text: text,
      words: words,
      characters: characters,
      charactersNoSpaces: charactersNoSpaces,
      lines: lines,
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  static const _sample =
      'Paste or type your text here to see live word, character, and line counts.';

  TextStats _stats = const TextStats(
    text: '',
    words: 0,
    characters: 0,
    charactersNoSpaces: 0,
    lines: 0,
  );

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = _sample;
    _stats = TextStats.of(_sample);
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    setState(() => _stats = TextStats.of(_controller.text));
  }

  void _clear() {
    _controller.clear();
    _onChanged();
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Count'),
        actions: [
          IconButton(
            tooltip: 'Clear text',
            icon: const Icon(Icons.clear_all),
            onPressed: _clear,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Paste your text here…',
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
            Row(
              children: [
                _StatCard(label: 'Words', value: _stats.words),
                const SizedBox(width: 12),
                _StatCard(label: 'Characters', value: _stats.characters),
                const SizedBox(width: 12),
                _StatCard(
                  label: 'No spaces',
                  value: _stats.charactersNoSpaces,
                ),
                const SizedBox(width: 12),
                _StatCard(label: 'Lines', value: _stats.lines),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$value',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
