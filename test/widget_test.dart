import 'package:flutter_test/flutter_test.dart';

import 'package:stella_bus_jam/app.dart';

void main() {
  testWidgets('Stella Bus Jam app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const StellaBusJamApp());

    expect(find.text('STELLA BUS JAM'), findsOneWidget);
    expect(find.text('PASSENGER QUEUES'), findsOneWidget);
    expect(find.text('BUS PARKING'), findsOneWidget);
  });
}