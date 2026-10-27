import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/flashcard.dart';

class FlipCard extends StatelessWidget {
  const FlipCard({
    super.key,
    required this.card,
    required this.revealed,
    required this.onToggle,
  });

  final Flashcard card;
  final bool revealed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: _flipTransition,
        child: revealed
            ? _Face(
                key: const ValueKey('answer'),
                label: 'ANSWER',
                text: card.answer,
                color: colorScheme.secondaryContainer,
              )
            : _Face(
                key: const ValueKey('question'),
                label: 'QUESTION',
                text: card.question,
                color: colorScheme.primaryContainer,
              ),
      ),
    );
  }

  Widget _flipTransition(Widget child, Animation<double> animation) {
    final rotation = Tween<double>(begin: math.pi, end: 0).animate(animation);
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, orientedChild) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(rotation.value),
          child: orientedChild,
        );
      },
    );
  }
}

class _Face extends StatelessWidget {
  const _Face({
    super.key,
    required this.label,
    required this.text,
    required this.color,
  });

  final String label;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 280,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(height: 12),
          Text(
            text,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
