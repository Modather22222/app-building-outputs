import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_check/main.dart';

void main() {
  testWidgets('app renders empty state and can add an item with quantity', (tester) async {
    await tester.pumpWidget(const GroceryCheckApp());

    expect(find.text('Grocery Check'), findsOneWidget);
    expect(find.text('Your list is empty'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Milk');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('0 of 1 done'), findsOneWidget);
  });
}
