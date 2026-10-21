import 'package:drift/drift.dart' hide Column;
import 'package:flexify/alpha/alpha_prefs.dart';
import 'package:flexify/workout/gym_workout_page.dart';
import 'package:flexify/workout/plate_calculator_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_app.dart';

void main() {
  test('a stored cable step falls back to the default handle', () {
    final prefs = AlphaPrefs();
    prefs.applyStored({
      'cableStep': 'broken',
      'barKg': 15,
      'plates': [10, 5],
    });
    expect(prefs.dumbbellHandleKg, 2.5);
    expect(prefs.barKg, 15);
    expect(prefs.plates, [10, 5]);

    prefs.applyStored({'dumbbellHandleKg': 0, 'cableStep': 15});
    expect(prefs.dumbbellHandleKg, 2.5);
    prefs.applyStored({'dumbbellHandleKg': '2.5'});
    expect(prefs.dumbbellHandleKg, 2.5);
    prefs.applyStored({'dumbbellHandleKg': 5});
    expect(prefs.dumbbellHandleKg, 5);
  });

  testWidgets('the calculator opens from the button and loads one dumbbell', (
    tester,
  ) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    addTearDown(() {
      alphaPrefs.dumbbellHandleKg = 2.5;
    });
    final plan =
        await (harness.database.plans.select()
              ..where((row) => row.id.equals(1)))
            .getSingle();

    await harness.pump(
      tester,
      GymWorkoutPage(plan: plan),
      surfaceSize: const Size(400, 900),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PlateCalculatorPage), findsNothing);

    await tester.tap(find.byIcon(Icons.calculate_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(PlateCalculatorPage), findsOneWidget);
    expect(find.text('Cable stack'), findsNothing);
    expect(find.text('Dumbbell'), findsOneWidget);

    await tester.tap(find.text('Dumbbell'));
    await tester.pumpAndSettle();
    expect(find.text('Handle'), findsOneWidget);
    expect(find.text('Per dumbbell'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '21');
    await tester.pump();
    expect(find.text('Extra weight: 1 kg'), findsOneWidget);
  });
}
