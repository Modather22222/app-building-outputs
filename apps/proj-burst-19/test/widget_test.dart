import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unit_quiz/main.dart';

void main() {
  testWidgets('app renders the first quiz question', (tester) async {
    await tester.pumpWidget(const UnitQuizApp());

    expect(find.text('Unit Quiz'), findsOneWidget);
    expect(find.textContaining('What is'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });
}
