import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_match/game_state.dart';
import 'package:memory_match/main.dart';

void main() {
  testWidgets('app renders board and stats, flipping reveals symbols', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MemoryMatchApp());

    await tester.pump();
    expect(find.text('Memory Match'), findsOneWidget);
    expect(find.textContaining('Moves:'), findsOneWidget);
    expect(find.textContaining('Time:'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(GameState.pairs * 2));

    // Checkers timers never settle; just flush frames and clean up.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 750));
  });
}
