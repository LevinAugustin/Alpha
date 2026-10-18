import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flexify/database/database.dart';
import 'package:flexify/database/exercise_set_repository.dart';
import 'package:flexify/exercises/custom_exercise.dart';
import 'package:flexify/exercises/custom_exercise_page.dart';
import 'package:flexify/import/hevy_import.dart';
import 'package:flexify/import/import_cleanup.dart';
import 'package:flexify/import/import_export_page.dart';
import 'package:flexify/main.dart';
import 'package:flexify/shell/start_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock_tests.dart';
import 'support/fixtures.dart';
import 'support/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('English weekday plans become German and other titles stay', () async {
    db = testDb();
    addTearDown(db.close);
    final tuesday = await db.plans.insertOne(
      PlansCompanion.insert(days: 'Tuesday', title: const Value('Tuesday')),
    );
    final empty = await db.plans.insertOne(
      PlansCompanion.insert(days: 'Thursday'),
    );
    final named = await db.plans.insertOne(
      PlansCompanion.insert(days: 'Monday', title: const Value('Push')),
    );

    await renameEnglishPlanTitles(db);

    final rows = await db.select(db.plans).get();
    expect(rows.firstWhere((row) => row.id == tuesday).title, 'Dienstag');
    expect(rows.firstWhere((row) => row.id == tuesday).days, 'Tuesday');
    expect(rows.firstWhere((row) => row.id == empty).title, 'Donnerstag');
    expect(rows.firstWhere((row) => row.id == named).title, 'Push');
    expect(rows.firstWhere((row) => row.id == named).days, 'Monday');
  });

  test('two workouts on the same day advance the next plan', () async {
    db = testDb();
    addTearDown(db.close);
    final plans = await db.select(db.plans).get();
    for (final plan in plans) {
      await (db.update(db.plans)..where((row) => row.id.equals(plan.id))).write(
        PlansCompanion(sequence: Value(plan.id)),
      );
    }
    final now = DateTime(2026, 10, 14, 18);
    expect((await suggestedNextPlan(now))!.title, 'Montag');

    Future<void> finish(int hour) {
      return db.workouts.insertOne(
        WorkoutsCompanion.insert(
          startedAt: DateTime(2026, 10, 14, hour),
          endedAt: Value(DateTime(2026, 10, 14, hour, 45)),
        ),
      );
    }

    await finish(9);
    expect((await suggestedNextPlan(now))!.title, 'Mittwoch');
    await finish(12);
    expect((await suggestedNextPlan(now))!.title, 'Freitag');
    expect(await finishedWorkoutsThisWeek(now), 2);
  });

  test('legacy custom exercises get muscles and stay editable', () async {
    db = testDb();
    addTearDown(db.close);
    final id = await db
        .into(db.exercises)
        .insert(
          ExercisesCompanion.insert(
            name: 'Old Curl',
            kind: 'strength',
            displayUnit: 'kg',
            catalogId: const Value('eigen-old-curl'),
            categoryName: const Value('Chest'),
            muscle: const Value('Chest'),
          ),
        );
    final before = await (db.select(
      db.exercises,
    )..where((row) => row.id.equals(id))).getSingle();
    expect(isCustomExercise(before), isTrue);
    expect(await repairLegacyCustomExercises(db), 1);
    final after = await (db.select(
      db.exercises,
    )..where((row) => row.id.equals(id))).getSingle();
    expect(after.categoryName, 'Brust');
    expect(after.equipment, 'Körpergewicht');
    expect(after.primaryMuscles, '["brust"]');

    final catalogId = await db
        .into(db.exercises)
        .insert(
          ExercisesCompanion.insert(
            name: 'Bench',
            kind: 'strength',
            displayUnit: 'kg',
            catalogId: const Value('bankdruecken-langhantel'),
            equipment: const Value('Langhantel'),
          ),
        );
    final catalog = await (db.select(
      db.exercises,
    )..where((row) => row.id.equals(catalogId))).getSingle();
    expect(isCustomExercise(catalog), isFalse);
    expect(await repairLegacyCustomExercises(db), 0);
    final untouched = await (db.select(
      db.exercises,
    )..where((row) => row.id.equals(catalogId))).getSingle();
    expect(untouched.equipment, 'Langhantel');
  });

  test(
    'cleanup removes import stubs and keeps hand-entered workouts',
    () async {
      db = testDb();
      addTearDown(db.close);
      final exerciseId = await db
          .into(db.exercises)
          .insert(exerciseFixture('Curl'));
      final handPlan = await db.plans.insertOne(
        PlansCompanion.insert(days: '', title: const Value('Hand')),
      );
      final importPlan = await db.plans.insertOne(
        PlansCompanion.insert(days: '', title: const Value('Hevy')),
      );
      final day = DateTime(2026, 5, 2, 10);
      final handId = await db.workouts.insertOne(
        WorkoutsCompanion.insert(
          planId: Value(handPlan),
          startedAt: day,
          endedAt: Value(day.add(const Duration(hours: 1))),
        ),
      );
      final stamp = DateTime(2026, 5, 1, 12, 0, 4);
      final stubId = await db.workouts.insertOne(
        WorkoutsCompanion.insert(
          planId: Value(importPlan),
          startedAt: stamp,
          endedAt: Value(stamp),
        ),
      );
      final mixedId = await db.workouts.insertOne(
        WorkoutsCompanion.insert(
          planId: Value(handPlan),
          startedAt: stamp,
          endedAt: Value(DateTime(2026, 5, 1, 12, 0, 4)),
        ),
      );
      await insertExerciseSet(
        db,
        exerciseId: exerciseId,
        workoutId: handId,
        exerciseSet: exerciseSetFixture('Curl', created: day),
      );
      await insertExerciseSet(
        db,
        exerciseId: exerciseId,
        workoutId: stubId,
        exerciseSet: exerciseSetFixture('Curl', created: stamp),
      );

      final preview = await previewImportCleanup(db);
      expect(preview.workoutIds.toSet(), {stubId, mixedId});
      expect(preview.planIds, [importPlan]);
      expect(preview.groups.single.workouts, 2);

      await applyImportCleanup(db, preview);

      final workouts = await db.select(db.workouts).get();
      expect(workouts.map((row) => row.id), [handId]);
      final plans = await db.select(db.plans).get();
      expect(plans.any((row) => row.id == handPlan), isTrue);
      expect(plans.any((row) => row.id == importPlan), isFalse);
      final sets = await db.select(db.exerciseSets).get();
      expect(sets, hasLength(1));
      expect(sets.single.workoutId, handId);
    },
  );

  test('theme figures are cropped to the character', () {
    final bear = _pngSize(File('assets/figures/eisbaer.png'));
    final bunny = _pngSize(File('assets/figures/bunny.png'));
    final gorilla = _pngSize(File('assets/figures/gorilla_body.png'));
    expect(bear.$1, lessThan(800));
    expect(bear.$2, greaterThan(600));
    expect(bunny.$1, lessThan(500));
    expect(bunny.$2, greaterThan(600));
    expect(gorilla, (855, 949));
  });

  testWidgets('template names stay on one line at 360 dp', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    const name = 'Kurzhantel-Schrägbankdrücken mit einem sehr langen Namen';
    final preview = parseWorkoutCsv('''
title,start_time,exercise_title,weight_kg,reps
Training,"17 Okt. 2026, 13:20","$name",20,10
''');
    await harness.pump(
      tester,
      ImportPreviewPage(preview: preview!),
      locale: const Locale('de'),
      surfaceSize: const Size(360, 800),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 Trainings, 1 Sätze'), findsOneWidget);
    final label = find.text(name);
    expect(label, findsOneWidget);
    expect(tester.getSize(label).height, lessThan(40));
    expect(
      tester.getTopLeft(find.byType(DropdownButton<int>)).dy,
      greaterThan(tester.getTopLeft(label).dy),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a second tap does not import twice', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    await harness.database
        .into(harness.database.exercises)
        .insert(
          ExercisesCompanion.insert(
            name: 'Curl',
            germanName: const Value('Curl'),
            kind: 'strength',
            displayUnit: 'kg',
          ),
        );
    final preview = parseWorkoutCsv('''
title,start_time,end_time,exercise_title,weight_kg,reps
Training,"17 Okt. 2026, 13:20","17 Okt. 2026, 14:00",Curl,20,10
''');
    final gate = Completer<void>();
    await harness.pump(
      tester,
      ImportPreviewPage(preview: preview!, pause: () => gate.future),
      locale: const Locale('de'),
    );
    await tester.pumpAndSettle();

    final button = find.byKey(const Key('apply-import'));
    await tester.tap(button);
    await tester.pump();
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(button, warnIfMissed: false);
    gate.complete();
    await tester.pumpAndSettle();

    expect(
      await harness.database.select(harness.database.workouts).get(),
      hasLength(1),
    );
    expect(
      await harness.database.select(harness.database.exerciseSets).get(),
      hasLength(1),
    );
  });

  testWidgets('saving without a movement explains why', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    await harness.pump(
      tester,
      const CustomExercisePage(),
      locale: const Locale('en'),
      surfaceSize: const Size(400, 900),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('custom-exercise-name')),
      'Curl',
    );
    await tester.tap(find.byType(FilterChip).first);
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('save-custom-exercise')),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('save-custom-exercise')));
    await tester.pump();

    expect(find.text('Choose a movement.'), findsOneWidget);
    final saved = await (harness.database.select(
      harness.database.exercises,
    )..where((row) => row.name.equals('Curl'))).get();
    expect(saved, isEmpty);
  });

  testWidgets('the streak tile keeps the full label at large text', (
    tester,
  ) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    await harness.pump(
      tester,
      const SizedBox(
        width: 160,
        child: HomeStatTile(
          icon: Icons.calendar_view_week,
          text: '0 Wochen in Folge',
        ),
      ),
      locale: const Locale('de'),
      surfaceSize: const Size(360, 200),
      textScaler: const TextScaler.linear(3),
    );
    await tester.pumpAndSettle();
    expect(find.text('0 Wochen in Folge'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

(int, int) _pngSize(File file) {
  final bytes = file.readAsBytesSync();
  final width =
      (bytes[16] << 24) | (bytes[17] << 16) | (bytes[18] << 8) | bytes[19];
  final height =
      (bytes[20] << 24) | (bytes[21] << 16) | (bytes[22] << 8) | bytes[23];
  return (width, height);
}
