import 'package:drift/drift.dart' hide Column;
import 'package:flexify/alpha/alpha_prefs.dart';
import 'package:flexify/exercises/custom_exercise_page.dart';
import 'package:flexify/graph/add_exercise_page.dart';
import 'package:flexify/plan/edit_plan_page.dart';
import 'package:flexify/workout/gym_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';
import 'support/test_app.dart';

void main() {
  testWidgets(
    'the plan editor picks an exercise, re-enables one, and keeps order',
    (tester) async {
      final harness = await FlexifyTestHarness.create();
      addTearDown(harness.database.close);
      final database = harness.database;
      await database.planExercises.deleteAll();
      await database.plans.deleteAll();
      final plan = planFixture(
        id: 1,
        days: 'Monday',
        title: 'Push',
        sequence: 1,
      );
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
        exercise: 'Back extension',
        enabled: false,
        sequence: 1,
      );
      await ensureExerciseFixture(database, 'Arnold press');

      await harness.pump(
        tester,
        EditPlanPage(plan: plan),
        surfaceSize: const Size(420, 1600),
      );
      await tester.pumpAndSettle();

      expect(find.text('Barbell bench press'), findsOneWidget);
      expect(find.text('Back extension'), findsNothing);
      expect(find.byType(AddExercisePage), findsNothing);

      await _pick(tester, 'Back extension');
      expect(find.text('Back extension'), findsOneWidget);
      expect(find.text('Barbell bench press'), findsOneWidget);

      await _pick(tester, 'Arnold press');
      expect(find.text('Arnold press'), findsOneWidget);

      await tester.tap(find.widgetWithText(ListTile, 'Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('create-own-exercise')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('custom-exercise-name')),
        'Mein Curl',
      );
      await tester.tap(find.byType(FilterChip).first);
      await tester.pump();
      await _scrollForm(
        tester,
        find.byKey(const Key('custom-exercise-motion')),
      );
      await tester.tap(find.byKey(const Key('custom-exercise-motion')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Press').last);
      await tester.pumpAndSettle();
      await _scrollForm(tester, find.byKey(const Key('save-custom-exercise')));
      await tester.tap(find.byKey(const Key('save-custom-exercise')));
      await tester.pumpAndSettle();

      expect(find.text('Mein Curl'), findsOneWidget);
      expect(find.byType(AddExercisePage), findsNothing);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final rows =
          await (database.select(database.planExercises).join([
                  innerJoin(
                    database.exercises,
                    database.exercises.id.equalsExp(
                      database.planExercises.exerciseId,
                    ),
                  ),
                ])
                ..where(database.planExercises.planId.equals(1))
                ..orderBy([OrderingTerm.asc(database.planExercises.sequence)]))
              .get();
      final names = [
        for (final row in rows)
          if (row.readTable(database.planExercises).enabled)
            row.readTable(database.exercises).name,
      ];
      expect(names, [
        'Barbell bench press',
        'Back extension',
        'Arnold press',
        'Mein Curl',
      ]);
    },
  );

  testWidgets('saving without a primary muscle explains why', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    await harness.pump(
      tester,
      const CustomExercisePage(),
      surfaceSize: const Size(400, 1400),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('custom-exercise-name')),
      'Curl',
    );
    await _scrollForm(tester, find.byKey(const Key('custom-exercise-motion')));
    await tester.tap(find.byKey(const Key('custom-exercise-motion')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Press').last);
    await tester.pumpAndSettle();
    await _scrollForm(tester, find.byKey(const Key('save-custom-exercise')));
    await tester.tap(find.byKey(const Key('save-custom-exercise')));
    await tester.pump();
    await _scrollForm(
      tester,
      find.byKey(const Key('custom-exercise-error')),
      delta: -400,
    );

    expect(find.text('Choose a primary muscle.'), findsWidgets);
    expect(find.byKey(const Key('custom-exercise-error')), findsOneWidget);
    final saved = await (harness.database.select(
      harness.database.exercises,
    )..where((row) => row.name.equals('Curl'))).get();
    expect(saved, isEmpty);
  });

  testWidgets('backing out of studio choice does not start the workout', (
    tester,
  ) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    addTearDown(() async {
      alphaPrefs.gyms = [GymPlace(id: 'default', name: 'Studio')];
      alphaPrefs.activeGymId = 'default';
      await alphaPrefs.save();
    });
    alphaPrefs.gyms = [
      GymPlace(id: 'a', name: 'Eins'),
      GymPlace(id: 'b', name: 'Zwei'),
    ];
    await alphaPrefs.save();
    final before = await harness.database
        .select(harness.database.workouts)
        .get();
    final plan = await (harness.database.plans.select()..limit(1)).getSingle();

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
      locale: const Locale('de'),
      surfaceSize: const Size(400, 900),
    );
    await tester.tap(find.text('open-workout'));
    await _until(tester, find.text('Studio wählen'));
    expect(find.text('Studio wählen'), findsOneWidget);

    await tester.binding.handlePopRoute();
    for (
      var i = 0;
      i < 20 && find.byType(GymWorkoutPage).evaluate().isNotEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(GymWorkoutPage), findsNothing);
    expect(find.text('open-workout'), findsOneWidget);
    expect(
      await harness.database.select(harness.database.workouts).get(),
      hasLength(before.length),
    );
  });

  testWidgets('the previous column stays on one line at large text', (
    tester,
  ) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    addTearDown(harness.timerState.stopTimer);
    final plan = await (harness.database.plans.select()..limit(1)).getSingle();
    await harness.pump(
      tester,
      GymWorkoutPage(plan: plan),
      locale: const Locale('de'),
      surfaceSize: const Size(360, 900),
      textScaler: const TextScaler.linear(1.3),
    );
    await _until(tester, find.text('VORHERIGE'));
    final header = find.text('VORHERIGE');
    expect(header, findsWidgets);
    for (final element in header.evaluate()) {
      final paragraph = element.renderObject! as RenderParagraph;
      final text = paragraph.text.toPlainText();
      final boxes = paragraph.getBoxesForSelection(
        TextSelection(baseOffset: 0, extentOffset: text.length),
      );
      final tops = boxes.map((box) => box.top.round()).toSet();
      expect(tops, hasLength(1));
    }
  });
}

Future<void> _scrollForm(
  WidgetTester tester,
  Finder target, {
  double delta = 300,
}) async {
  final scrollable = find
      .descendant(
        of: find.byKey(const Key('custom-exercise-form')),
        matching: find.byType(Scrollable),
      )
      .first;
  await tester.scrollUntilVisible(target, delta, scrollable: scrollable);
  final box = tester.renderObject<RenderBox>(target);
  final center = box.localToGlobal(box.size.center(Offset.zero));
  final height = tester.view.physicalSize.height / tester.view.devicePixelRatio;
  if (center.dy < 8 || center.dy > height - 8) {
    await tester.drag(scrollable, Offset(0, height / 2 - center.dy));
    await tester.pumpAndSettle();
  }
}

Future<void> _until(WidgetTester tester, Finder target) async {
  for (var i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (target.evaluate().isNotEmpty) return;
  }
}

Future<void> _pick(WidgetTester tester, String name) async {
  await tester.tap(find.widgetWithText(ListTile, 'Add exercise'));
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('exercise-picker')), findsOneWidget);
  await tester.enterText(
    find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    ),
    name,
  );
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(ListTile, name),
    ),
  );
  await tester.pumpAndSettle();
}
