
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrack/main.dart';

void main() {
  testWidgets('NuTrack app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NuTrackApp());

    expect(find.text('Welcome to NuTrack!'), findsOneWidget);
  });
}
