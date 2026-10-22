import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' hide isNull;
import 'package:flexify/database/database.dart';
import 'package:flexify/database/exercise_de_catalog.dart';
import 'package:flexify/database/exercise_set_repository.dart';
import 'package:flexify/exercises/custom_exercise.dart';
import 'package:flexify/exercises/custom_exercise_page.dart';
import 'package:flexify/exercises/exercise_detail_page.dart';
import 'package:flexify/main.dart';
import 'package:flexify/shell/exercises_page.dart';
import 'package:flexify/workout/gym_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_app.dart';

import 'mock_tests.dart';

void main() {
  test('custom exercises keep history and count each side', () async {
    db = testDb();
    addTearDown(db.close);
    final saved = await saveCustomExercise(
      db,
      const CustomExerciseDraft(
        name: 'Reverse Butterfly',
        category: 'Schultern',
        primaryMuscles: ['schulter_hinten'],
        secondaryMuscles: ['oberer_ruecken'],
        equipment: 'Maschine',
        movement: 'ziehen',
        family: 'reverse-butterfly',
        unilateral: true,
      ),
    );
    expect(saved.catalogId, 'eigen-reverse-butterfly');
    expect(saved.einseitig, isTrue);
    expect(saved.germanName, 'Reverse Butterfly');

    final again = await saveCustomExercise(
      db,
      const CustomExerciseDraft(
        name: 'Reverse Butterfly',
        category: 'Schultern',
        primaryMuscles: ['schulter_hinten'],
        secondaryMuscles: [],
        equipment: 'Kabelzug',
        movement: 'ziehen',
      ),
    );
    expect(again.catalogId, 'eigen-reverse-butterfly-2');

    final now = DateTime(2026, 10, 17, 18);
    await insertExerciseSet(
      db,
      exerciseId: saved.id,
      exerciseSet: ExerciseSetView(
        id: 0,
        bodyWeight: 0,
        cardio: false,
        created: now,
        distance: 0,
        duration: 0,
        name: saved.name,
        reps: 10,
        unit: 'kg',
        weight: 20,
        side: 'links',
      ),
    );
    await insertExerciseSet(
      db,
      exerciseId: saved.id,
      exerciseSet: ExerciseSetView(
        id: 0,
        bodyWeight: 0,
        cardio: false,
        created: now,
        distance: 0,
        duration: 0,
        name: saved.name,
        reps: 8,
        unit: 'kg',
        weight: 20,
        side: 'rechts',
      ),
    );
    final sets = await db.exerciseSets.select().get();
    final volume = sets.fold<double>(
      0,
      (sum, set) => sum + (set.loadKg ?? 0) * (set.reps ?? 0),
    );
    expect(volume, 360);
    expect(sets.map((set) => set.loadKg).reduce((a, b) => a! > b! ? a : b), 20);
    expect(sets.map((set) => set.side).toSet(), {'links', 'rechts'});

    final heavier = await insertExerciseSet(
      db,
      exerciseId: saved.id,
      exerciseSet: ExerciseSetView(
        id: 0,
        bodyWeight: 0,
        cardio: false,
        created: now.add(const Duration(days: 1)),
        distance: 0,
        duration: 0,
        name: saved.name,
        reps: 6,
        unit: 'kg',
        weight: 22,
        side: 'links',
      ),
    );
    expect(await isBestExerciseSet(db, heavier), isTrue);

    await deleteCustomExercise(db, saved);
    final archived =
        await (db.exercises.select()..where((row) => row.id.equals(saved.id)))
            .getSingle();
    expect(archived.archived, isTrue);
    expect(await db.exerciseSets.select().get(), hasLength(3));
  });

  testWidgets('acceptance screens show family, pull search and a side set', (
    tester,
  ) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    db = harness.database;
    await importExerciseCatalogJson(
      harness.database,
      File('assets/exercises/exercises_de.json').readAsStringSync(),
      legacyMapRaw: File('assets/exercises/legacy_map.json').readAsStringSync(),
    );
    final bench =
        await (harness.database.exercises.select()
              ..where((row) => row.catalogId.equals('bankdruecken-langhantel')))
            .getSingle();
    expect(bench.familie, 'bankdruecken');
    expect(bench.position, 'flach');
    await harness.pump(
      tester,
      ExerciseDetailPage(exercise: bench),
      locale: const Locale('de'),
      surfaceSize: const Size(390, 844),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final variant = find.byKey(const Key('family-bankdruecken-kurzhantel'));
    await tester.ensureVisible(variant);
    await tester.pump(const Duration(milliseconds: 300));
    expect(variant, findsOneWidget);
    expect(find.textContaining('flach', skipOffstage: false), findsWidgets);
    await _shot(tester, 'family_variants');

    final custom = await saveCustomExercise(
      harness.database,
      const CustomExerciseDraft(
        name: 'Reverse Butterfly',
        category: 'Schultern',
        primaryMuscles: ['schulter_hinten'],
        secondaryMuscles: ['oberer_ruecken'],
        equipment: 'Maschine',
        movement: 'ziehen',
        unilateral: true,
      ),
    );
    await harness.pump(
      tester,
      const Scaffold(body: ExercisesPage()),
      locale: const Locale('de'),
      surfaceSize: const Size(390, 1600),
    );
    await tester.enterText(find.byType(TextField), 'Pull');
    await tester.pump(const Duration(milliseconds: 400));
    final results = find.descendant(
      of: find.byKey(const Key('exercise-results')),
      matching: find.byType(Scrollable),
    );
    for (final name in const [
      'Face Pulls',
      'Bizepscurls mit SZ-Stange',
      'Hammercurls',
      'Reverse Butterfly',
    ]) {
      final position = tester.state<ScrollableState>(results).position;
      position.jumpTo(0);
      await tester.pump(const Duration(milliseconds: 50));
      final target = find.text(name);
      for (var i = 0; i < 40 && target.evaluate().isEmpty; i++) {
        await tester.drag(results, const Offset(0, -500));
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(target, findsWidgets, reason: name);
    }
    expect(find.text('Bankdrücken'), findsNothing);
    expect(find.text('Bewegung'), findsOneWidget);
    await _shot(tester, 'pull_search');

    await harness.pump(
      tester,
      const CustomExercisePage(initialName: 'Einarmiges Seitheben'),
      locale: const Locale('de'),
      surfaceSize: const Size(390, 844),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Übung erstellen'), findsOneWidget);
    await _shot(tester, 'custom_exercise');

    final planId = await harness.database.plans.insertOne(
      PlansCompanion.insert(days: '', title: const Value('Seite')),
    );
    await harness.database.planExercises.insertOne(
      PlanExercisesCompanion.insert(
        enabled: true,
        exerciseId: custom.id,
        planId: planId,
      ),
    );
    final plan =
        await (harness.database.plans.select()
              ..where((row) => row.id.equals(planId)))
            .getSingle();
    await harness.pump(
      tester,
      GymWorkoutPage(plan: plan),
      locale: const Locale('de'),
      surfaceSize: const Size(390, 844),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(Key('split-sides-${custom.id}')));
    await tester.pump();
    await tester.enterText(find.byKey(Key('set-kg-${custom.id}-0')), '16');
    await tester.enterText(find.byKey(Key('set-reps-${custom.id}-0')), '12');
    await tester.enterText(
      find.byKey(Key('set-reps-right-${custom.id}-0')),
      '10',
    );
    await tester.pump();
    await _shot(tester, 'unilateral_set');
    await tester.tap(find.byKey(Key('set-check-${custom.id}-0')));
    await tester.pump(const Duration(milliseconds: 400));
    final sets = await harness.database.exerciseSets.select().get();
    expect(sets, hasLength(2));
    expect(sets.map((set) => (set.side, set.reps)).toSet(), {
      ('links', 12.0),
      ('rechts', 10.0),
    });
    final volume = sets.fold<double>(
      0,
      (sum, set) => sum + (set.loadKg ?? 0) * (set.reps ?? 0),
    );
    expect(volume, 352);
    await harness.timerState.stopTimer();
  });

  testWidgets('family variants stay visible across categories', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    db = harness.database;
    await importExerciseCatalogJson(
      harness.database,
      File('assets/exercises/exercises_de.json').readAsStringSync(),
    );
    final dips =
        await (harness.database.exercises.select()
              ..where((row) => row.catalogId.equals('dips')))
            .getSingle();
    expect(dips.categoryName, 'Trizeps');
    expect(dips.familie, 'dips');
    final chestDips =
        await (harness.database.exercises.select()
              ..where((row) => row.catalogId.equals('dips-brust')))
            .getSingle();
    expect(chestDips.categoryName, 'Brust');
    expect(chestDips.familie, 'dips');
    await harness.pump(
      tester,
      ExerciseDetailPage(exercise: dips),
      locale: const Locale('de'),
      surfaceSize: const Size(390, 1400),
    );
    await tester.pump();
    final chest = find.byKey(const Key('family-dips-brust'));
    await tester.ensureVisible(chest);
    await tester.pump();
    expect(chest, findsOneWidget);
    expect(find.text('Brust-Dips · Brust'), findsOneWidget);

    await tester.tap(chest);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const Key('family-dips')), findsOneWidget);
    expect(find.textContaining('· Trizeps'), findsWidgets);
  });
}

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.pump();
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byType(RepaintBoundary).first,
  );
  final image = await tester
      .runAsync(() => boundary.toImage(pixelRatio: 2))
      .timeout(const Duration(seconds: 3), onTimeout: () => null);
  if (image == null) return;
  final bytes = await tester.runAsync(
    () => image.toByteData(format: ui.ImageByteFormat.png),
  );
  final directory = Directory('/opt/cursor/artifacts/screenshots');
  directory.createSync(recursive: true);
  File(
    '${directory.path}/$name.png',
  ).writeAsBytesSync(bytes!.buffer.asUint8List());
}
