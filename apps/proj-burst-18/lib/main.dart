import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const TypingSprintApp());
}

const int _durationSeconds = 30;
const String _appTitle = 'Typing Sprint';

const List<String> _wordPool = [
  'the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can', 'her',
  'was', 'one', 'our', 'out', 'day', 'get', 'has', 'him', 'his', 'how',
  'man', 'new', 'now', 'old', 'see', 'two', 'way', 'who', 'boy', 'did',
  'its', 'let', 'put', 'say', 'she', 'too', 'use', 'that', 'with', 'have',
  'this', 'will', 'your', 'from', 'they', 'know', 'want', 'been', 'good',
  'much', 'some', 'time', 'very', 'when', 'come', 'here', 'just', 'like',
  'long', 'make', 'many', 'more', 'only', 'over', 'such', 'take', 'than',
  'them', 'well', 'were', 'what', 'about', 'after', 'again', 'other',
  'right', 'think', 'there', 'these', 'thing', 'those', 'where', 'which',
  'while', 'world', 'would', 'write', 'years', 'people', 'first', 'water',
  'place', 'great', 'still', 'small', 'large', 'point', 'every', 'found',
  'answer', 'school', 'should', 'system', 'number', 'person', 'part',
  'work', 'back', 'call', 'even', 'most', 'must', 'need', 'went', 'young',
];

enum _Phase { idle, running, done }

class TypingSprintApp extends StatelessWidget {
  const TypingSprintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: const SprintScreen(),
    );
  }
}

class SprintScreen extends StatefulWidget {
  const SprintScreen({super.key});

  @override
  State<SprintScreen> createState() => _SprintScreenState();
}

class _SprintScreenState extends State<SprintScreen> {
  _Phase _phase = _Phase.idle;
  int _secondsLeft = _durationSeconds;
  int _current = 0;
  int _correct = 0;
  int _typed = 0;
  List<String> _words = const [];
  Timer? _timer;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _start() {
    _timer?.cancel();
    setState(() {
      _phase = _Phase.running;
      _secondsLeft = _durationSeconds;
      _current = 0;
      _correct = 0;
      _typed = 0;
      _words = List.of(_wordPool)..shuffle(Random());
      _controller.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!mounted || _phase != _Phase.running) return;
    setState(() {
      if (_secondsLeft > 0) _secondsLeft--;
    });
    if (_secondsLeft == 0) _finish();
  }

  void _finish() {
    _timer?.cancel();
    setState(() => _phase = _Phase.done);
  }

  void _grade(String token) {
    if (_phase != _Phase.running || token.isEmpty) return;
    setState(() {
      _typed++;
      if (token.toLowerCase() == _words[_current]) _correct++;
      _current++;
      _ensureWords();
    });
  }

  void _ensureWords() {
    while (_words.length < _current + 40) {
      _words.addAll(List.of(_wordPool)..shuffle(Random()));
    }
  }

  void _onChanged(String text) {
    var pending = text;
    var graded = false;
    while (pending.contains(' ')) {
      final index = pending.indexOf(' ');
      final token = pending.substring(0, index).trim();
      pending = pending.substring(index + 1);
      if (token.isNotEmpty) {
        _grade(token);
        graded = true;
      }
    }
    if (graded) {
      _controller.text = pending;
      _controller.selection = TextSelection.collapsed(offset: pending.length);
    }
  }

  void _onSubmitted(String value) {
    final token = value.trim();
    if (token.isEmpty) return;
    _grade(token);
    _controller.clear();
  }

  int get _wpm => (_correct * 60 / _durationSeconds).round();
  int get _accuracy =>
      _typed == 0 ? 100 : ((_correct / _typed) * 100).round();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(_appTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: switch (_phase) {
          _Phase.idle => _buildIdle(context),
          _Phase.running => _buildRunning(context),
          _Phase.done => _buildResults(context),
        },
      ),
    );
  }

  Widget _buildIdle(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.keyboard_rounded,
              size: 96,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '$_durationSeconds seconds.\nHow fast can you type?',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              key: const Key('start_button'),
              onPressed: _start,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start sprint'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRunning(BuildContext context) {
    final theme = Theme.of(context);
    final upcoming = _words
        .skip(_current)
        .take(30)
        .toList(growable: false);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                color: _secondsLeft <= 5
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '$_secondsLeft s',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: _secondsLeft <= 5 ? theme.colorScheme.error : null,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '$_correct correct',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _secondsLeft / _durationSeconds,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var i = 0; i < upcoming.length; i++)
                    _WordChip(
                      word: upcoming[i],
                      state: i == 0
                          ? _WordChipState.current
                          : _WordChipState.upcoming,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: true,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.none,
            smartDashesType: SmartDashesType.disabled,
            smartQuotesType: SmartQuotesType.disabled,
            decoration: InputDecoration(
              labelText: 'Type the highlighted word, then space',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: 'Submit word',
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () => _onSubmitted(_controller.text),
              ),
            ),
            onChanged: _onChanged,
            onSubmitted: _onSubmitted,
          ),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events_rounded,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text('Sprint complete!', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 24),
            Text(
              '$_wpm',
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            Text('words per minute', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatChip(
                  icon: Icons.check_circle_outline,
                  label: '$_correct correct',
                ),
                const SizedBox(width: 12),
                _StatChip(
                  icon: Icons.track_changes,
                  label: '$_accuracy% accuracy',
                ),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              key: const Key('restart_button'),
              onPressed: _start,
              icon: const Icon(Icons.replay_rounded),
              label: const Text('Run again'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _WordChipState { current, upcoming }

class _WordChip extends StatelessWidget {
  const _WordChip({required this.word, required this.state});

  final String word;
  final _WordChipState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrent = state == _WordChipState.current;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isCurrent ? theme.colorScheme.primaryContainer : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        word,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          color: isCurrent
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, size: 18, color: theme.colorScheme.primary),
      label: Text(label),
    );
  }
}
