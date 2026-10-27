import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quick_notes/main.dart';

void main() {
  testWidgets('app shows the notes list and search field', (tester) async {
    await tester.pumpWidget(const QuickNotesApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Quick Notes'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Ideas'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
