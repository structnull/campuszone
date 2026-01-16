import 'package:flutter_test/flutter_test.dart';
import 'package:campuszone/app.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusZoneApp());
    expect(find.byType(CampusZoneApp), findsOneWidget);
  });
}
