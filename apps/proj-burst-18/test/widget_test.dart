import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typing_sprint/main.dart';

void main() {
  testWidgets('renders the start screen', (tester) async {
    await tester.pumpWidget(const TypingSprintApp());
    await tester.pump();

    expect(find.text('Typing Sprint'), findsOneWidget);
    expect(find.byKey(const Key('start_button')), findsOneWidget);
  });
}
