import 'package:flutter_test/flutter_test.dart';

import 'package:flashcards/main.dart';
import 'package:flashcards/state/deck_controller.dart';

void main() {
  testWidgets('pumps the app and shows the first flashcard', (tester) async {
    await tester.pumpWidget(const FlashcardsApp());

    expect(find.text('Card 1 of 8'), findsOneWidget);
    expect(
      find.text(DeckController.defaultDeck.first.question),
      findsOneWidget,
    );
    expect(find.text('Tap the card to reveal the answer'), findsOneWidget);
  });

  testWidgets('flipping a card and grading advances the deck', (tester) async {
    await tester.pumpWidget(const FlashcardsApp());

    await tester.tap(find.text('Capital of France?'));
    await tester.pumpAndSettle();
    expect(find.text('Paris'), findsOneWidget);

    await tester.tap(find.text('Correct'));
    await tester.pumpAndSettle();
    expect(find.text('Card 2 of 8'), findsOneWidget);
    expect(
      find.text(DeckController.defaultDeck[1].question),
      findsOneWidget,
    );
  });
}
