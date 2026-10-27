import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tip_splitter/main.dart';

void main() {
  testWidgets('renders the splitter screen', (tester) async {
    await tester.pumpWidget(const TipSplitterApp());

    expect(find.text('Tip Splitter'), findsOneWidget);
    expect(find.byKey(const ValueKey('per-person')), findsOneWidget);
    expect(find.text('Round up each share'), findsOneWidget);
  });
}
