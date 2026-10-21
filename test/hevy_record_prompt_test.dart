import 'package:drift/drift.dart' hide Column;
import 'package:flexify/alpha/alpha_prefs.dart';
import 'package:flexify/import/hevy_apply.dart';
import 'package:flexify/import/hevy_import.dart';
import 'package:flexify/workout/gym_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_app.dart';

void main() {
  testWidgets('a checked set uses imported history on the default studio', (
    tester,
  ) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    addTearDown(harness.timerState.stopTimer);
    alphaPrefs.activeGymId = 'default';
    await _importBench(harness, kg: 100, reps: 5);

    await _openBench(tester, harness);
    expect(find.text('100 kg × 5'), findsWidgets);

    await _check(tester, kg: '80', reps: '8');
    expect(find.text('NEW RECORD!'), findsNothing);

    await tester.tap(find.byKey(const Key('set-check-3-0')));
    await tester.pumpAndSettle();
    await _check(tester, kg: '120', reps: '3');
    expect(find.text('NEW RECORD!'), findsOneWidget);
    await tester.tap(find.text('Keep going'));
    await tester.pumpAndSettle();
    await harness.timerState.stopTimer();
  });
}

Future<void> _importBench(
  FlexifyTestHarness harness, {
  required double kg,
  required double reps,
}) async {
  final database = harness.database;
  final exercise =
      await (database.exercises.select()
            ..where((row) => row.name.equals('Barbell bench press')))
          .getSingle();
  final started = DateTime(2024, 3, 1, 18);
  await applyWorkoutImport(
    database: database,
    sets: [
      ImportedSet(
        workoutTitle: 'Hevy Push',
        started: started,
        ended: started,
        exercise: exercise.name,
        kg: kg,
        reps: reps,
        warmup: false,
      ),
    ],
    templates: [
      ImportedTemplate(
        title: 'Hevy Push',
        exercises: [exercise.name],
        setCounts: {exercise.name: 1},
        lastWeights: {exercise.name: kg},
      ),
    ],
    match: (name) => name == exercise.name ? exercise : null,
    existingPlanCount: 3,
    existingTitles: {'Montag', 'Mittwoch', 'Freitag'},
  );
}

Future<void> _openBench(WidgetTester tester, FlexifyTestHarness harness) async {
  final plan =
      await (harness.database.plans.select()..where((row) => row.id.equals(1)))
          .getSingle();
  await harness.pump(
    tester,
    GymWorkoutPage(plan: plan),
    surfaceSize: const Size(400, 900),
  );
  await tester.pumpAndSettle();
}

Future<void> _check(
  WidgetTester tester, {
  required String kg,
  required String reps,
}) async {
  await tester.enterText(find.byKey(const Key('set-kg-3-0')), kg);
  await tester.enterText(find.byKey(const Key('set-reps-3-0')), reps);
  await tester.tap(find.byKey(const Key('set-check-3-0')));
  await tester.pumpAndSettle();
}
