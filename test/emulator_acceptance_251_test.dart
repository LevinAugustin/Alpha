import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flexify/alpha/alpha_prefs.dart';
import 'package:flexify/alpha/live_workout.dart';
import 'package:flexify/database/catalog_seed.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/database/exercise_de_catalog.dart';
import 'package:flexify/database/exercise_set_repository.dart';
import 'package:flexify/import/hevy_apply.dart';
import 'package:flexify/import/hevy_import.dart';
import 'package:flexify/import/import_cleanup.dart';
import 'package:flexify/main.dart';
import 'package:flexify/plan/edit_plan_page.dart';
import 'package:flexify/shell/live_workout_bar.dart';
import 'package:flexify/shell/start_page.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flexify/workout/gym_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock_tests.dart';
import 'support/fixtures.dart';
import 'support/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('an exact synonym outranks a name-word prefix', () {
    expect(
      exerciseSearchRank(
        name: 'latziehen-breit',
        germanName: 'Latziehen',
        aliases: 'Latzug|Lat Pulldown',
        query: 'latzug',
      ),
      3,
    );
    expect(
      exerciseSearchRank(
        name: 'legacy-latzug',
        germanName: 'Full Range Motion Latzug',
        query: 'latzug',
      ),
      4,
    );
    expect(
      compareExerciseSearch(
        query: 'latzug',
        leftName: 'legacy-latzug',
        leftGermanName: 'Full Range Motion Latzug',
        leftCatalog: false,
        rightName: 'latziehen-breit',
        rightGermanName: 'Latziehen',
        rightAliases: 'Latzug',
        rightCatalog: true,
      ),
      greaterThan(0),
    );
    expect(
      compareExerciseSearch(
        query: 'lat',
        leftName: 'legacy-lat',
        leftGermanName: 'Lat Raise Alt',
        leftCatalog: false,
        rightName: 'latziehen-breit',
        rightGermanName: 'Latziehen',
        rightCatalog: true,
      ),
      greaterThan(0),
    );
  });

  test('a database full of legacy rows keeps catalog hits first', () async {
    final database = testDb();
    addTearDown(database.close);
    final raw = File('assets/exercises/exercises_de.json').readAsStringSync();
    final imported = await importExerciseCatalogJson(database, raw);
    expect(imported.skipped, isEmpty);
    const legacyCount = 900;
    await database.batch((batch) {
      batch.insertAll(database.exercises, [
        for (var index = 0; index < legacyCount; index++)
          ExercisesCompanion.insert(
            name: 'Legacy 2.4 $index',
            kind: 'strength',
            displayUnit: 'kg',
            germanName: Value(switch (index) {
              0 => 'Full Range Motion Latzug',
              1 => 'Alter Bizeps am Kabelgerat',
              2 => 'Lat Raise Alt',
              _ => 'Altes Gerät $index',
            }),
          ),
      ]);
    });
    final rows = await database.exercises.select().get();
    expect(
      rows.where((row) => (row.catalogId ?? '').isEmpty).length,
      greaterThanOrEqualTo(legacyCount),
    );

    List<Exercise> ranked(String query) {
      final hits =
          [
            for (final exercise in rows)
              if (exerciseMatchesQuery(
                name: exercise.name,
                germanName: exercise.germanName,
                aliases: exercise.aliases,
                movement: exercise.bewegung,
                category: exercise.categoryName,
                equipment: exercise.equipment,
                muscle: exercise.muscle,
                primaryMuscles: exercise.primaryMuscles,
                secondaryMuscles: exercise.secondaryMuscles,
                familie: exercise.familie,
                grip: exercise.griff,
                position: exercise.position,
                query: query,
              ))
                exercise,
          ]..sort(
            (left, right) => compareExerciseSearch(
              query: query,
              leftName: left.name,
              leftGermanName: left.germanName,
              leftAliases: left.aliases,
              leftCatalog: isCatalogExercise(
                catalogId: left.catalogId,
                catalogSource: left.catalogSource,
              ),
              rightName: right.name,
              rightGermanName: right.germanName,
              rightAliases: right.aliases,
              rightCatalog: isCatalogExercise(
                catalogId: right.catalogId,
                catalogSource: right.catalogSource,
              ),
            ),
          );
      return hits;
    }

    final latzug = ranked('latzug');
    expect(latzug.first.catalogId, 'latziehen-breit');
    final legacyLatzug = latzug.indexWhere(
      (row) => row.germanName == 'Full Range Motion Latzug',
    );
    expect(legacyLatzug, greaterThan(0));
    expect(
      latzug
          .take(legacyLatzug)
          .every(
            (row) => isCatalogExercise(
              catalogId: row.catalogId,
              catalogSource: row.catalogSource,
            ),
          ),
      isTrue,
    );
    for (final id in const [
      'latziehen-breit',
      'latziehen-eng',
      'latziehen-untergriff',
      'latziehen-nacken',
      'latziehen-einarmig',
      'latziehen-maschine',
    ]) {
      expect(latzug.any((row) => row.catalogId == id), isTrue, reason: id);
    }

    final lat = ranked('lat');
    expect(lat.first.catalogId, 'latziehen-breit');
    final legacyLat = lat.indexWhere(
      (row) => row.germanName == 'Lat Raise Alt',
    );
    expect(legacyLat, greaterThan(0));
    final seitheben = [
      for (final row in lat)
        if ((row.catalogId ?? '').startsWith('seitheben-')) row.catalogId,
    ];
    expect(seitheben, isNotEmpty);
    for (final id in const [
      'latziehen-breit',
      'latziehen-eng',
      'latziehen-untergriff',
      'latziehen-nacken',
      'latziehen-einarmig',
      'latziehen-maschine',
    ]) {
      final index = lat.indexWhere((row) => row.catalogId == id);
      expect(index, greaterThanOrEqualTo(0), reason: id);
      for (final shoulder in seitheben) {
        expect(
          index,
          lessThan(lat.indexWhere((row) => row.catalogId == shoulder)),
          reason: '$id before $shoulder',
        );
      }
    }

    final cable = ranked('Bizeps Kabel');
    final catalogCable = cable.indexWhere(
      (row) => row.catalogId == 'bizepscurls-kabel',
    );
    final legacyCable = cable.indexWhere(
      (row) => row.germanName == 'Alter Bizeps am Kabelgerat',
    );
    expect(catalogCable, greaterThanOrEqualTo(0));
    expect(legacyCable, greaterThan(catalogCable));
  });

  test('a 2.5.1 import without an end time survives cleanup', () async {
    final database = testDb();
    addTearDown(database.close);
    final exerciseId = await database
        .into(database.exercises)
        .insert(
          ExercisesCompanion.insert(
            name: 'Curl',
            germanName: const Value('Curl'),
            kind: 'strength',
            displayUnit: 'kg',
          ),
        );
    final exercise = await (database.select(
      database.exercises,
    )..where((row) => row.id.equals(exerciseId))).getSingle();
    final started = DateTime(2026, 6, 1, 18);
    await applyWorkoutImport(
      database: database,
      sets: [
        for (var index = 0; index < 3; index++)
          ImportedSet(
            workoutTitle: 'Push ohne Ende',
            started: started,
            ended: null,
            exercise: 'Curl',
            kg: 20,
            reps: 8,
            warmup: false,
          ),
      ],
      templates: [
        ImportedTemplate(
          title: 'Push ohne Ende',
          exercises: const ['Curl'],
          setCounts: const {'Curl': 3},
          lastWeights: const {'Curl': 20},
        ),
      ],
      match: (name) => name == exercise.name ? exercise : null,
      existingPlanCount: 3,
      existingTitles: {'Montag', 'Mittwoch', 'Freitag'},
    );
    final imported = await (database.select(
      database.workouts,
    )..where((row) => row.importBatch.isNotNull())).getSingle();
    expect(imported.importBatch, startsWith('2.5.1-'));
    expect(importedStub(imported.startedAt, imported.endedAt), isTrue);
    await (database.update(database.workouts)
          ..where((row) => row.id.equals(imported.id)))
        .write(const WorkoutsCompanion(exerciseOrder: Value('4,5,6')));
    final opened = await (database.select(
      database.workouts,
    )..where((row) => row.id.equals(imported.id))).getSingle();
    expect(opened.importBatch, imported.importBatch);

    final stamp = DateTime(2026, 5, 1, 12, 0, 4);
    final oldStub = await database.workouts.insertOne(
      WorkoutsCompanion.insert(startedAt: stamp, endedAt: Value(stamp)),
    );
    await insertExerciseSet(
      database,
      exerciseId: exerciseId,
      workoutId: oldStub,
      exerciseSet: exerciseSetFixture('Curl', created: stamp),
    );
    final markedSingle = await database.workouts.insertOne(
      WorkoutsCompanion.insert(
        startedAt: stamp,
        endedAt: Value(stamp),
        importBatch: const Value('2.5.1-manual'),
      ),
    );
    await insertExerciseSet(
      database,
      exerciseId: exerciseId,
      workoutId: markedSingle,
      exerciseSet: exerciseSetFixture('Curl', created: stamp),
    );
    final keptOpen = DateTime(2026, 4, 2, 9);
    final unmarkedSession = await database.workouts.insertOne(
      WorkoutsCompanion.insert(startedAt: keptOpen, endedAt: Value(keptOpen)),
    );
    for (var index = 0; index < 3; index++) {
      await insertExerciseSet(
        database,
        exerciseId: exerciseId,
        workoutId: unmarkedSession,
        exerciseSet: exerciseSetFixture('Curl', created: keptOpen),
      );
    }

    final preview = await previewImportCleanup(database);
    expect(preview.workoutIds, contains(oldStub));
    expect(preview.workoutIds, isNot(contains(imported.id)));
    expect(preview.workoutIds, isNot(contains(markedSingle)));
    expect(preview.workoutIds, isNot(contains(unmarkedSession)));
    await applyImportCleanup(database, preview);
    final left = await database.select(database.workouts).get();
    expect(left.map((row) => row.id).toSet(), {
      imported.id,
      markedSingle,
      unmarkedSession,
    });
    expect(
      await (database.select(
        database.exerciseSets,
      )..where((row) => row.workoutId.equals(imported.id))).get(),
      hasLength(3),
    );
  });

  test('startup restores the unfinished workout', () async {
    final database = testDb();
    addTearDown(() async {
      liveWorkout.value = null;
      await database.close();
    });
    db = database;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    await database.workouts.insertOne(
      WorkoutsCompanion.insert(
        planId: const Value(1),
        startedAt: yesterday,
        endedAt: Value(yesterday.add(const Duration(hours: 1))),
      ),
    );
    final openId = await database.workouts.insertOne(
      WorkoutsCompanion.insert(
        planId: const Value(1),
        startedAt: DateTime.now(),
      ),
    );
    final bench = await (database.select(
      database.exercises,
    )..where((row) => row.name.equals('Barbell bench press'))).getSingle();
    await insertExerciseSet(
      database,
      exerciseId: bench.id,
      workoutId: openId,
      exerciseSet: exerciseSetFixture('Barbell bench press'),
    );

    await restoreLiveWorkout(database);

    expect(liveWorkout.value?.planId, 1);
    expect(liveWorkout.value?.workoutId, openId);
    expect(liveWorkout.value?.title, 'Montag');
    expect(liveWorkout.value?.exercise, 'Barbell bench press');
  });

  testWidgets('home offers to resume the restored workout', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    addTearDown(() => liveWorkout.value = null);
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    await harness.database.workouts.insertOne(
      WorkoutsCompanion.insert(
        planId: const Value(1),
        startedAt: yesterday,
        endedAt: Value(yesterday.add(const Duration(hours: 1))),
      ),
    );
    await harness.database.workouts.insertOne(
      WorkoutsCompanion.insert(
        planId: const Value(1),
        startedAt: DateTime.now(),
      ),
    );
    await restoreLiveWorkout(harness.database);
    await harness.pump(
      tester,
      Theme(
        data: alphaThemeData(AlphaPalette.tiefschwarz),
        child: const StartPage(),
      ),
      locale: const Locale('de'),
      surfaceSize: const Size(400, 900),
    );
    await tester.pumpAndSettle();

    expect(find.text('Training fortsetzen'), findsOneWidget);
    expect(find.textContaining('Training starten'), findsNothing);
    await tester.tap(find.byKey(const Key('start-workout')));
    await tester.pumpAndSettle();
    final open = await (harness.database.select(
      harness.database.workouts,
    )..where((row) => row.endedAt.isNull())).get();
    expect(open, hasLength(1));
    expect(open.single.planId, 1);
  });

  testWidgets('reopening the live workout does not ask for a studio', (
    tester,
  ) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    final previousGyms = alphaPrefs.gyms;
    final previousGym = alphaPrefs.activeGymId;
    addTearDown(() async {
      alphaPrefs.gyms = previousGyms;
      alphaPrefs.activeGymId = previousGym;
      await alphaPrefs.save();
    });
    alphaPrefs.gyms = [
      GymPlace(id: 'eins', name: 'Studio Eins'),
      GymPlace(id: 'zwei', name: 'Studio Zwei'),
    ];
    await alphaPrefs.save();
    final plan =
        await (harness.database.plans.select()
              ..where((row) => row.id.equals(1)))
            .getSingle();
    await harness.database.workouts.insertOne(
      WorkoutsCompanion.insert(
        planId: Value(plan.id),
        startedAt: DateTime.now(),
      ),
    );

    await harness.pump(
      tester,
      Theme(
        data: alphaThemeData(AlphaPalette.tiefschwarz),
        child: GymWorkoutPage(plan: plan),
      ),
      locale: const Locale('de'),
      surfaceSize: const Size(400, 900),
    );
    await tester.pumpAndSettle();

    expect(find.text('Studio wählen'), findsNothing);
    expect(find.byKey(const Key('finish-workout')), findsOneWidget);
  });

  testWidgets('a new workout still asks which studio to use', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    final previousGyms = alphaPrefs.gyms;
    final previousGym = alphaPrefs.activeGymId;
    addTearDown(() async {
      alphaPrefs.gyms = previousGyms;
      alphaPrefs.activeGymId = previousGym;
      await alphaPrefs.save();
    });
    alphaPrefs.gyms = [
      GymPlace(id: 'eins', name: 'Studio Eins'),
      GymPlace(id: 'zwei', name: 'Studio Zwei'),
    ];
    await alphaPrefs.save();
    final plan =
        await (harness.database.plans.select()
              ..where((row) => row.id.equals(2)))
            .getSingle();

    await harness.pump(
      tester,
      Theme(
        data: alphaThemeData(AlphaPalette.tiefschwarz),
        child: GymWorkoutPage(plan: plan),
      ),
      locale: const Locale('de'),
      surfaceSize: const Size(400, 900),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Studio wählen'), findsOneWidget);
    expect(find.text('Studio Eins'), findsOneWidget);
  });

  testWidgets('the live bar subtitle stays visible at text scale 1.3', (
    tester,
  ) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    addTearDown(() => liveWorkout.value = null);
    const exercise = 'Kurzhantel-Schrägbankdrücken';
    liveWorkout.value = LiveWorkout(
      planId: 1,
      workoutId: 1,
      title: 'Montag',
      exercise: exercise,
    );
    await harness.pump(
      tester,
      Theme(
        data: alphaThemeData(AlphaPalette.tiefschwarz),
        child: const Scaffold(body: LiveWorkoutBar()),
      ),
      locale: const Locale('de'),
      textScaler: const TextScaler.linear(1.3),
      surfaceSize: const Size(360, 800),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final text = tester.getRect(find.text(exercise));
    final bar = tester.getRect(find.byKey(const Key('live-workout-bar')));
    expect(text.top, greaterThanOrEqualTo(bar.top));
    expect(text.bottom, lessThanOrEqualTo(bar.bottom));
    expect(text.height, greaterThan(0));
  });

  testWidgets('finishing removes the running rest timer', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    addTearDown(harness.timerState.stopTimer);
    final plan =
        await (harness.database.plans.select()
              ..where((row) => row.id.equals(1)))
            .getSingle();
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
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('set-kg-3-0')), '50');
    await tester.enterText(find.byKey(const Key('set-reps-3-0')), '8');
    await tester.tap(find.byKey(const Key('set-check-3-0')));
    await tester.pumpAndSettle();
    expect(harness.timerState.timer.isRunning(), isTrue);

    await tester.tap(find.byKey(const Key('finish-workout')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-finish')));
    await tester.pumpAndSettle();

    expect(harness.timerState.timer.isRunning(), isFalse);
    expect(liveWorkout.value, isNull);
  });

  testWidgets('editing a plan is titled Plan bearbeiten', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    final plan =
        await (harness.database.plans.select()
              ..where((row) => row.id.equals(1)))
            .getSingle();
    await harness.pump(
      tester,
      EditPlanPage(plan: plan.toCompanion(false)),
      locale: const Locale('de'),
      surfaceSize: const Size(400, 900),
    );
    await tester.pumpAndSettle();
    expect(find.text('Plan bearbeiten'), findsOneWidget);
    expect(find.text('Plan hinzufügen'), findsNothing);

    await harness.pump(
      tester,
      const EditPlanPage(plan: PlansCompanion(days: Value(''))),
      locale: const Locale('de'),
      surfaceSize: const Size(400, 900),
    );
    await tester.pumpAndSettle();
    expect(find.text('Plan hinzufügen'), findsOneWidget);
    expect(find.text('Plan bearbeiten'), findsNothing);
  });
}
