import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../state/deck_controller.dart';
import '../widgets/flip_card.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key, required this.controller});

  final DeckController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => controller.isFinished
          ? _Summary(controller: controller)
          : _Study(controller: controller),
    );
  }
}

class _Study extends StatelessWidget {
  const _Study({required this.controller});

  final DeckController controller;

  @override
  Widget build(BuildContext context) {
    final card = controller.currentCard;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Card ${controller.index + 1} of ${controller.totalCards}'),
        actions: [
          IconButton(
            tooltip: 'Reset tallies',
            icon: const Icon(Icons.refresh),
            onPressed: controller.reset,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (controller.index + (controller.isRevealed ? 0.5 : 0)) /
                  controller.totalCards,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: FlipCard(
                      card: card,
                      revealed: controller.isRevealed,
                      onToggle: controller.toggleReveal,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: _CardTally(card: card),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: controller.isRevealed
                  ? Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: () => controller.grade(false),
                            icon: const Icon(Icons.close),
                            label: const Text('Wrong'),
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.errorContainer,
                              foregroundColor: colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => controller.grade(true),
                            icon: const Icon(Icons.check),
                            label: const Text('Correct'),
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Tap the card to reveal the answer',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardTally extends StatelessWidget {
  const _CardTally({required this.card});

  final Flashcard card;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle, size: 18, color: Colors.green.shade600),
        const SizedBox(width: 4),
        Text('${card.correctCount}'),
        const SizedBox(width: 20),
        Icon(Icons.cancel, size: 18, color: Colors.red.shade400),
        const SizedBox(width: 4),
        Text('${card.wrongCount}'),
        const SizedBox(width: 20),
        Text(
          'seen ${card.timesSeen}x',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.controller});

  final DeckController controller;

  @override
  Widget build(BuildContext context) {
    final cards = controller.cards;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Deck complete')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'You marked ${controller.totalCorrect} correct and '
            '${controller.totalWrong} wrong.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  ListTile(
                    title: Text(cards[i].question),
                    subtitle: Text(cards[i].answer),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green.shade600,
                        ),
                        Text(' ${cards[i].correctCount}'),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.cancel,
                          size: 16,
                          color: colorScheme.error,
                        ),
                        Text(' ${cards[i].wrongCount}'),
                      ],
                    ),
                  ),
                  if (i != cards.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: controller.restartDeck,
            icon: const Icon(Icons.replay),
            label: const Text('Study again'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: controller.reset,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset tallies and restart'),
          ),
        ],
      ),
    );
  }
}
