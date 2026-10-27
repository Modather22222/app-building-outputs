import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:word_count/main.dart';

void main() {
  testWidgets('app renders with live counters', (WidgetTester tester) async {
    await tester.pumpWidget(const WordCountApp());

    expect(find.text('Word Count'), findsOneWidget);
    expect(find.text('Words'), findsOneWidget);
    expect(find.text('Characters'), findsOneWidget);
    expect(find.text('No spaces'), findsOneWidget);
    expect(find.text('Lines'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
