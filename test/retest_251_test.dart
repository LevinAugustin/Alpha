import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:flexify/database/catalog_seed.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/database/exercise_de_catalog.dart';
import 'package:flexify/exercises/custom_exercise.dart';
import 'package:flexify/exercises/custom_exercise_page.dart';
import 'package:flexify/shell/exercises_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock_tests.dart';
import 'support/test_app.dart';

void main() {
  setUpAll(mockTests);

  test(
    'legacy repair is indexed, once, and leaves unknown rows empty',
    () async {
      final database = testDb();
      addTearDown(database.close);
      final imported = await importExerciseCatalogJson(
        database,
        File('assets/exercises/exercises_de.json').readAsStringSync(),
      );
      expect(imported.skipped, isEmpty);
      final flexifyMap = File(
        'assets/exercises/flexify_mapping.json',
      ).readAsStringSync();

      await database.batch((batch) {
        batch.insertAll(database.exercises, [
          for (var index = 0; index < 920; index++)
            ExercisesCompanion.insert(
              name: _legacyName(index),
              kind: 'strength',
              displayUnit: 'kg',
              catalogId: index == 4
                  ? const Value('eigen-kept')
                  : const Value.absent(),
              catalogSource: index == 3 || index == 4
                  ? const Value('custom')
                  : const Value.absent(),
              categoryName: index == 3 || index == 4
                  ? const Value('Brust')
                  : const Value.absent(),
              muscle: index == 3 || index == 4
                  ? const Value('Brust')
                  : const Value.absent(),
              equipment: index == 3 || index == 4
                  ? const Value('Körpergewicht')
                  : const Value.absent(),
              primaryMuscles: index == 3 || index == 4
                  ? const Value('["brust"]')
                  : const Value.absent(),
              bewegung: index == 4
                  ? const Value('druecken')
                  : const Value.absent(),
            ),
        ]);
      });

      final before = await database.select(database.exercises).get();
      expect(
        before
            .where(
              (row) => isCatalogExercise(
                catalogId: row.catalogId,
                catalogSource: row.catalogSource,
              ),
            )
            .length,
        295,
      );
      expect(before.where(isCustomExercise).length, greaterThanOrEqualTo(920));

      final elapsed = Stopwatch()..start();
      final updated = await repairLegacyCustomExercises(
        database,
        flexifyMapRaw: flexifyMap,
      );
      elapsed.stop();
      expect(updated, greaterThan(0));
      expect(elapsed.elapsed, lessThan(const Duration(seconds: 2)));

      Future<Exercise> named(String name) {
        return (database.select(
          database.exercises,
        )..where((row) => row.name.equals(name))).getSingle();
      }

      for (final name in const [
        'Landmine Press Eigen',
        'Full Range Motion Latzug',
        'Überkopf Lat',
      ]) {
        final row = await named(name);
        expect(row.categoryName, isNull, reason: name);
        expect(row.muscle, isNull, reason: name);
        expect(row.equipment, isNull, reason: name);
        expect(row.primaryMuscles, isNull, reason: name);
      }

      final cleared = await named('Full Range Motion Latzug');
      expect(cleared.catalogSource, isNull);

      final kept = await named('Eigene Brust');
      expect(kept.catalogId, 'eigen-kept');
      expect(kept.categoryName, 'Brust');
      expect(kept.equipment, 'Körpergewicht');
      expect(kept.primaryMuscles, '["brust"]');
      expect(kept.bewegung, 'druecken');

      final seeded = await named('Barbell Guillotine Bench Press');
      expect(seeded.categoryName, 'Brust');
      expect(seeded.equipment, 'Langhantel');
      expect(seeded.primaryMuscles, contains('brust'));

      final extra = await database
          .into(database.exercises)
          .insert(
            ExercisesCompanion.insert(
              name: 'Nach der Reparatur',
              kind: 'strength',
              displayUnit: 'kg',
            ),
          );
      final second = Stopwatch()..start();
      expect(
        await repairLegacyCustomExercises(database, flexifyMapRaw: flexifyMap),
        0,
      );
      second.stop();
      expect(second.elapsed, lessThan(const Duration(milliseconds: 500)));
      final skipped = await (database.select(
        database.exercises,
      )..where((row) => row.id.equals(extra))).getSingle();
      expect(skipped.categoryName, isNull);
      expect(skipped.equipment, isNull);
      final setting = await database.select(database.settings).getSingle();
      expect(setting.legacyRepairVersion, legacyCustomRepairVersion);
    },
  );

  test('a disabled plan row stays and takes the active exercise', () async {
    final database = testDb();
    addTearDown(database.close);
    final targetId = await database
        .into(database.exercises)
        .insert(
          ExercisesCompanion.insert(
            name: 'Latziehen Platzhalter',
            kind: 'strength',
            displayUnit: 'kg',
          ),
        );
    final sourceId = await database
        .into(database.exercises)
        .insert(
          ExercisesCompanion.insert(
            name: 'Lat Pull runter',
            kind: 'strength',
            displayUnit: 'kg',
          ),
        );
    await database.planExercises.insertOne(
      PlanExercisesCompanion.insert(
        enabled: false,
        exerciseId: targetId,
        planId: 1,
        sequence: const Value(0),
        maxSets: const Value(1),
        timers: const Value(true),
      ),
    );
    await database.planExercises.insertOne(
      PlanExercisesCompanion.insert(
        enabled: true,
        exerciseId: sourceId,
        planId: 1,
        sequence: const Value(4),
        maxSets: const Value(5),
        warmupSets: const Value(2),
        repMin: const Value(6),
        repMax: const Value(12),
        restMs: const Value(90000),
        timers: const Value(false),
      ),
    );

    final imported = await importExerciseCatalogJson(
      database,
      jsonEncode([
        {
          'id': 'latziehen-runter',
          'name_de': 'Latziehen nach unten',
          'synonyme': <String>[],
          'kategorie': 'Rücken',
          'primaermuskeln': ['latissimus'],
          'sekundaermuskeln': <String>[],
          'geraet': 'Kabelzug',
          'mechanik': 'grund',
          'ausfuehrung_de': <String>[],
          'tipps_de': <String>[],
          'bild': 'latziehen-runter.webp',
          'quelle': 'placeholder',
          'lizenz': 'placeholder',
          'familie': 'latziehen',
          'bewegung': 'ziehen',
          'einseitig': false,
        },
      ]),
      flexifyMapRaw: jsonEncode({
        'latziehen-runter': {
          'seed_namen': ['Latziehen Platzhalter', 'Lat Pull runter'],
          'aussortiert_naechste_entsprechung': <String>[],
        },
      }),
    );
    expect(imported.skipped, isEmpty);
    expect(imported.merged, 1);

    expect(
      await (database.select(
        database.exercises,
      )..where((row) => row.id.equals(sourceId))).getSingleOrNull(),
      isNull,
    );
    final plan =
        await (database.select(database.planExercises)..where(
              (row) => row.planId.equals(1) & row.exerciseId.equals(targetId),
            ))
            .getSingle();
    expect(plan.enabled, isTrue);
    expect(plan.sequence, 4);
    expect(plan.maxSets, 5);
    expect(plan.warmupSets, 2);
    expect(plan.repMin, 6);
    expect(plan.repMax, 12);
    expect(plan.restMs, 90000);
    expect(plan.timers, isFalse);
    final monday = await (database.select(
      database.plans,
    )..where((row) => row.id.equals(1))).getSingle();
    expect(monday.title, 'Montag');
  });

  testWidgets('an unmatched exercise can be assigned in the edit form', (
    tester,
  ) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    final id = await harness.database
        .into(harness.database.exercises)
        .insert(
          ExercisesCompanion.insert(
            name: 'Geheimübung',
            kind: 'strength',
            displayUnit: 'kg',
          ),
        );
    final exercise = await (harness.database.select(
      harness.database.exercises,
    )..where((row) => row.id.equals(id))).getSingle();
    await harness.pump(
      tester,
      CustomExercisePage(exercise: exercise),
      locale: const Locale('de'),
      surfaceSize: const Size(800, 2400),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nicht zugeordnet'), findsWidgets);
    expect(
      tester
          .widget<DropdownButtonFormField<String>>(
            find.byKey(const Key('custom-exercise-category')),
          )
          .initialValue,
      '',
    );

    await tester.tap(find.byKey(const Key('custom-exercise-category')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trizeps').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Trizeps').first);
    await tester.pump();
    expect(
      tester
          .widget<DropdownButtonFormField<String>>(
            find.byKey(const Key('custom-exercise-gear')),
          )
          .initialValue,
      '',
    );
    await tester.tap(find.byKey(const Key('custom-exercise-gear')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kurzhantel').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('custom-exercise-motion')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Drücken').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-custom-exercise')));
    await tester.pumpAndSettle();

    final saved = await (harness.database.select(
      harness.database.exercises,
    )..where((row) => row.id.equals(id))).getSingle();
    expect(saved.categoryName, 'Trizeps');
    expect(saved.equipment, 'Kurzhantel');
    expect(saved.primaryMuscles, contains('trizeps'));
    expect(saved.bewegung, 'druecken');
    expect(saved.catalogId, startsWith('eigen-'));
  });

  testWidgets('a new exercise search starts at the top', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    await harness.pump(
      tester,
      const Scaffold(body: ExercisesPage()),
      locale: const Locale('de'),
      surfaceSize: const Size(400, 320),
    );
    await tester.pumpAndSettle();
    final results = find.descendant(
      of: find.byKey(const Key('exercise-results')),
      matching: find.byType(Scrollable),
    );
    final position = tester.state<ScrollableState>(results).position;
    position.jumpTo(position.maxScrollExtent);
    await tester.pump();
    expect(position.pixels, greaterThan(0));
    await tester.enterText(find.byType(TextField), 'curl');
    await tester.pump();
    expect(position.pixels, 0);
    expect(find.text('Nicht zugeordnet'), findsWidgets);
  });
}

String _legacyName(int index) {
  return switch (index) {
    0 => 'Landmine Press Eigen',
    1 => 'Überkopf Lat',
    2 => 'Barbell Guillotine Bench Press',
    3 => 'Full Range Motion Latzug',
    4 => 'Eigene Brust',
    _ => 'Legacy 2.4 $index',
  };
}
