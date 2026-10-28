import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:quicknote/main.dart';

void main() {
  testWidgets('QuickNote renders the notes screen', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const QuickNoteApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('QuickNote'), findsOneWidget);
    expect(find.text('No notes yet'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
