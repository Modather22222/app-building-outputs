import 'package:flutter_test/flutter_test.dart';
import 'package:build_info_probe/main.dart';

void main() {
  testWidgets('stopwatch app shows core controls', (WidgetTester tester) async {
    await tester.pumpWidget(const StopwatchApp());

    expect(find.text('Stopwatch'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Lap'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
    expect(find.text('00:00.00'), findsOneWidget);
  });
}
