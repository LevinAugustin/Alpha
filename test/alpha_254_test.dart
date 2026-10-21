import 'package:drift/drift.dart' hide Column;
import 'package:flexify/alpha/live_workout.dart';
import 'package:flexify/native_timer_wrapper.dart';
import 'package:flexify/plan/edit_plan_page.dart';
import 'package:flexify/shell/live_workout_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';
import 'support/test_app.dart';

void main() {
  testWidgets('picking an active exercise stays put', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    final database = harness.database;
    await database.planExercises.deleteAll();
    await database.plans.deleteAll();
    final plan = planFixture(id: 1, days: 'Monday', title: 'Push', sequence: 1);
    await database.plans.insertOne(plan);
    await insertPlanExerciseFixture(
      database,
      planId: 1,
      exercise: 'Barbell bench press',
      sequence: 0,
    );
    await insertPlanExerciseFixture(
      database,
      planId: 1,
      exercise: 'Arnold press',
      sequence: 1,
    );

    await harness.pump(
      tester,
      EditPlanPage(plan: plan),
      surfaceSize: const Size(420, 900),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Add exercise'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'Barbell bench press',
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(ListTile, 'Barbell bench press'),
      ),
    );
    await tester.pump();

    expect(find.text('Already in this plan'), findsOneWidget);
    final bench = tester.getTopLeft(find.text('Barbell bench press').first);
    final arnold = tester.getTopLeft(find.text('Arnold press'));
    expect(bench.dy, lessThan(arnold.dy));
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('the live rest clock advances each second', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    addTearDown(() => liveWorkout.value = null);
    addTearDown(harness.timerState.stopTimer);
    await harness.pump(
      tester,
      const LiveWorkoutBar(),
      surfaceSize: const Size(400, 160),
    );
    liveWorkout.value = LiveWorkout(
      planId: 1,
      workoutId: 1,
      title: 'Push',
      exercise: 'Bench press',
    );
    harness.timerState.updateTimer(
      NativeTimerWrapper(
        const Duration(seconds: 10),
        Duration.zero,
        DateTime.now(),
        NativeTimerState.running,
      ),
    );
    await tester.pump();
    final before = tester.widget<Text>(
      find.byKey(const Key('live-rest-clock')),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 1100)),
    );
    await tester.pump(const Duration(seconds: 1));
    final after = tester.widget<Text>(find.byKey(const Key('live-rest-clock')));
    expect(after.data, isNot(before.data));
    liveWorkout.value = null;
    await tester.pump();
  });
}
