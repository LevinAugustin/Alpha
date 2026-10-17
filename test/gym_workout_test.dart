import 'package:drift/drift.dart' hide isNotNull;
import 'package:flexify/workout/gym_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_app.dart';

void main() {
  testWidgets('gym workout logs the session and leaves the template', (
    tester,
  ) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);

    final plan =
        await (harness.database.plans.select()
              ..where((row) => row.id.equals(1)))
            .getSingle();
    final templateBefore = await harness.database.planExercises.select().get();

    await harness.pump(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => GymWorkoutPage(plan: plan),
                ),
              );
            },
            child: const Text('open-workout'),
          ),
        ),
      ),
      surfaceSize: const Size(400, 900),
    );
    await tester.tap(find.text('open-workout'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('finish-workout')), findsOneWidget);
    expect(find.text('SATZ'), findsNothing);
    expect(find.text('SET'), findsWidgets);

    final kg = find.byKey(const Key('set-kg-3-0'));
    final reps = find.byKey(const Key('set-reps-3-0'));
    expect(kg, findsOneWidget);
    await tester.enterText(kg, '50');
    await tester.enterText(reps, '8');
    await tester.tap(find.byKey(const Key('set-check-3-0')));
    await tester.pumpAndSettle();

    final saved =
        await (harness.database.exerciseSets.select()
              ..where((row) => row.exerciseId.equals(3)))
            .get();
    expect(saved, hasLength(1));
    expect(saved.single.loadKg, 50);
    expect(saved.single.reps, 8);
    expect(saved.single.workoutId, isNotNull);

    await tester.tap(find.byKey(const Key('finish-workout')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-finish')));
    await tester.pumpAndSettle();

    final workout = await harness.database.workouts.select().getSingle();
    expect(workout.endedAt, isNotNull);
    expect(workout.planId, plan.id);

    final templateAfter = await harness.database.planExercises.select().get();
    expect(
      templateAfter.map((row) => row.exerciseId).toList(),
      templateBefore.map((row) => row.exerciseId).toList(),
    );

    await tester.tap(find.text('open-workout'));
    await tester.pumpAndSettle();
    expect(find.text('50 kg × 8'), findsWidgets);

    final active =
        await (harness.database.workouts.select()
              ..where((row) => row.endedAt.isNull()))
            .getSingle();
    expect(active.id, isNot(workout.id));
    final templateStill = await harness.database.planExercises.select().get();
    expect(
      templateStill.map((row) => row.exerciseId).toList(),
      templateBefore.map((row) => row.exerciseId).toList(),
    );
    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await harness.timerState.stopTimer();
  });
}
