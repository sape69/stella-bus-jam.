
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stella_bus_jam/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Stella Bus Jam home page starts', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StellaBusJamApp());

    await tester.pumpAndSettle();

    expect(
      find.text('WELCOME TO STELLA BUS JAM!'),
      findsOneWidget,
    );

    expect(
      find.text('PLAY LEVEL 1'),
      findsOneWidget,
    );

    expect(
      find.text('SELECT LEVEL'),
      findsOneWidget,
    );

    expect(
      find.text('TOTAL STARS'),
      findsOneWidget,
    );
  });
}
