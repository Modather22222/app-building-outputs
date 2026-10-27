import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tip_splitter/main.dart';

void main() {
  testWidgets('App renders and splits an equal bill', (tester) async {
    await tester.pumpWidget(const TipSplitterApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Tip Splitter'), findsOneWidget);

    // Enter an amount and add people.
    await tester.enterText(find.byType(TextField), '100');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pump();

    // 100 dollars among 3 people -> 33.33 each, no extra.
    expect(find.text('\$33.33'), findsOneWidget);
    expect(find.text('\$100.00'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    // Turn on rounding to the next dollar -> 34 each, 2.00 extra.
    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();
    expect(find.text('\$34.00'), findsOneWidget);
    expect(find.text('\$102.00'), findsOneWidget);
    expect(find.text('\$2.00'), findsOneWidget);
  });
}
