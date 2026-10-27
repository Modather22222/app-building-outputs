import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memory_match/game_state.dart';

void main() {
  runApp(const MemoryMatchApp());
}

class MemoryMatchApp extends StatelessWidget {
  const MemoryMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Match',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const GameScreen(),
    );
  }
}

String formatTime(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameState _game = GameState();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _game.newGame();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _game.tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _game.dispose();
    super.dispose();
  }

  void _restart() {
    _timer?.cancel();
    setState(() => _game.newGame());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _game.tick());
  }

  void _flip(int i) {
    setState(() => _game.flip(i));
    if (_game.isComplete) {
      _timer?.cancel();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('You win! 🎉'),
          content: Text(
            'All pairs matched in ${_game.moves} moves '
            'and ${formatTime(_game.elapsed)}.\n'
            'Best time so far: ${formatTime(_game.bestTime ?? _game.elapsed)} '
            '(${_game.bestMoves ?? _game.moves} moves).',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _restart();
              },
              child: const Text('Play again'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Match'),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: _game,
        builder: (context, _) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Moves: ${_game.moves}',
                      style: Theme.of(context).textTheme.titleMedium),
                  Text('Time: ${formatTime(_game.elapsed)}',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _game.bestTime == null
                    ? 'No best time yet'
                    : 'Best: ${formatTime(_game.bestTime!)} '
                        '(${_game.bestMoves} moves)',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _game.tiles.length,
                  itemBuilder: (context, i) {
                    final tile = _game.tiles[i];
                    final revealed = tile.faceUp || tile.matched;
                    return Card(
                      elevation: revealed ? 0 : 3,
                      color: tile.matched
                          ? Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withAlpha(120)
                          : null,
                      child: InkWell(
                        onTap: () => _flip(i),
                        child: Center(
                          child: Text(
                            revealed ? tile.card.symbol : '❓',
                            style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(fontSize: 34) ??
                                const TextStyle(fontSize: 34),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FilledButton.icon(
                onPressed: _restart,
                icon: const Icon(Icons.refresh),
                label: const Text('New game'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
