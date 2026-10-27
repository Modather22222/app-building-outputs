import 'package:dispatch_probe/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tap counter increments and displays the count', (tester) async {
    await tester.pumpWidget(const DispatchProbeApp());

    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.text('Tap'));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });
}
