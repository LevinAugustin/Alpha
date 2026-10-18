import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flexify/database/catalog_seed.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/database/exercise_de_catalog.dart';
import 'package:flexify/exercises/custom_exercise.dart';
import 'package:flexify/exercises/exercise_detail_page.dart';
import 'package:flexify/exercises/exercise_image.dart';
import 'package:flexify/main.dart';
import 'package:flexify/shell/exercises_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_app.dart';

import 'mock_tests.dart';

List<Map<String, dynamic>> _probeRows() {
  final decoded =
      jsonDecode(File('assets/exercises/exercises_de.json').readAsStringSync())
          as List;
  return [for (final row in decoded) Map<String, dynamic>.from(row as Map)];
}

void main() {
  setUp(() => db = testDb());

  test('catalog keeps existing exercise ids and reapplies the file', () async {
    final raw = File('assets/exercises/exercises_de.json').readAsStringSync();
    final legacyMap = File(
      'assets/exercises/legacy_map.json',
    ).readAsStringSync();
    final parsed = parseExerciseCatalog(raw);
    expect(parsed.skipped, isEmpty);
    expect(parsed.entries, hasLength(294));
    expect(parsed.entries.first.imageSource, isEmpty);
    expect(parsed.entries.first.imageLicense, isEmpty);
    expect(parsed.entries.last.id, 'scheiben-pinch');
    expect(
      parsed.entries
          .where((entry) => entry.category == 'Cardio')
          .map((entry) => entry.mechanic),
      everyElement(isEmpty),
    );
    final map = parseLegacyNameMap(legacyMap);
    expect(map.keys, hasLength(32));
    expect(parsed.entries.map((entry) => entry.id), containsAll(map.keys));

    final before =
        await (db.exercises.select()
              ..where((row) => row.name.equals('Barbell bench press')))
            .getSingle();
    final historyId = await db.exerciseSets.insertOne(
      ExerciseSetsCompanion.insert(
        exerciseId: before.id,
        timestamp: DateTime(2024, 5, 1),
        reps: const Value(8),
        loadKg: const Value(80),
      ),
    );
    final mediumId = await db.exercises.insertOne(
      ExercisesCompanion.insert(
        name: 'Barbell Bench Press - Medium Grip',
        kind: 'strength',
        displayUnit: 'kg',
      ),
    );
    final mediumSet = await db.exerciseSets.insertOne(
      ExerciseSetsCompanion.insert(
        exerciseId: mediumId,
        timestamp: DateTime(2024, 5, 2),
        reps: const Value(6),
        loadKg: const Value(90),
      ),
    );
    final mondayBench =
        await (db.planExercises.select()..where(
              (row) => row.planId.equals(1) & row.exerciseId.equals(before.id),
            ))
            .getSingle();
    final pull =
        await (db.exercises.select()
              ..where((row) => row.name.equals('Pull-up')))
            .getSingle();
    final wide =
        await (db.exercises.select()
              ..where((row) => row.name.equals('Wide-grip pull-up')))
            .getSingle();
    final fridayPull =
        await (db.planExercises.select()..where(
              (row) => row.planId.equals(3) & row.exerciseId.equals(pull.id),
            ))
            .getSingle();
    final widePlanId = await db.planExercises.insertOne(
      PlanExercisesCompanion.insert(
        enabled: true,
        exerciseId: wide.id,
        planId: 3,
      ),
    );
    final pullSet = await db.exerciseSets.insertOne(
      ExerciseSetsCompanion.insert(
        exerciseId: pull.id,
        timestamp: DateTime(2024, 5, 3),
        reps: const Value(8),
      ),
    );
    final wideSet = await db.exerciseSets.insertOne(
      ExerciseSetsCompanion.insert(
        exerciseId: wide.id,
        timestamp: DateTime(2024, 5, 4),
        reps: const Value(6),
      ),
    );
    final hanging =
        await (db.exercises.select()
              ..where((row) => row.name.equals('Hanging leg raise')))
            .getSingle();
    final legRaise =
        await (db.exercises.select()
              ..where((row) => row.name.equals('Leg raise')))
            .getSingle();
    final hangingSet = await db.exerciseSets.insertOne(
      ExerciseSetsCompanion.insert(
        exerciseId: hanging.id,
        timestamp: DateTime(2024, 5, 5),
        reps: const Value(10),
      ),
    );
    final legSet = await db.exerciseSets.insertOne(
      ExerciseSetsCompanion.insert(
        exerciseId: legRaise.id,
        timestamp: DateTime(2024, 5, 6),
        reps: const Value(12),
      ),
    );
    final untouched =
        await (db.exercises.select()
              ..where((row) => row.name.equals('Neck curl')))
            .getSingle();

    final first = await importExerciseCatalogJson(
      db,
      raw,
      legacyMapRaw: legacyMap,
    );
    expect(first.skipped, isEmpty);
    expect(first.inserted, 274);
    expect(first.updated, 20);
    expect(first.merged, 3);

    final after =
        await (db.exercises.select()..where((row) => row.id.equals(before.id)))
            .getSingle();
    expect(after.name, 'Barbell bench press');
    expect(after.catalogId, 'bankdruecken-langhantel');
    expect(after.germanName, 'Bankdrücken');
    expect(after.muscle, 'Brust');
    expect(after.equipment, 'Langhantel');
    expect(after.primaryMuscles, '["brust"]');
    expect(after.secondaryMuscles, '["schulter_vorne","trizeps"]');
    expect(after.kind, 'strength');
    expect(
      after.catalogSource,
      'free-exercise-db: Barbell_Bench_Press_-_Medium_Grip',
    );
    expect(after.catalogLicense, 'Unlicense');
    expect(after.imageSource, '');
    expect(after.imageLicense, '');
    expect(
      after.alternatives,
      '["bankdruecken-kurzhantel","bankdruecken-multipresse","brustpresse-maschine"]',
    );
    expect(after.image, 'assets/exercises/img/bankdruecken-langhantel.webp');
    expect(after.aliases, contains('Flachbankdrücken'));
    expect(after.aliases, contains('Barbell Bench Press - Medium Grip'));
    expect(
      exerciseMatchesQuery(
        name: after.name,
        germanName: after.germanName,
        aliases: after.aliases,
        query: 'Flachbankdrücken',
      ),
      isTrue,
    );
    expect(
      await (db.exercises.select()..where((row) => row.id.equals(mediumId)))
          .getSingleOrNull(),
      isNull,
    );
    expect(
      (await (db.exerciseSets.select()
                ..where((row) => row.id.equals(historyId)))
              .getSingle())
          .exerciseId,
      before.id,
    );
    expect(
      (await (db.exerciseSets.select()
                ..where((row) => row.id.equals(mediumSet)))
              .getSingle())
          .exerciseId,
      before.id,
    );
    expect(
      (await (db.planExercises.select()
                ..where((row) => row.id.equals(mondayBench.id)))
              .getSingle())
          .exerciseId,
      before.id,
    );

    final keptPull =
        await (db.exercises.select()..where((row) => row.id.equals(pull.id)))
            .getSingle();
    expect(keptPull.name, 'Pull-up');
    expect(keptPull.catalogId, 'klimmzuege');
    expect(keptPull.aliases, contains('Wide-grip pull-up'));
    expect(
      exerciseMatchesQuery(
        name: keptPull.name,
        germanName: keptPull.germanName,
        aliases: keptPull.aliases,
        query: 'Wide-grip pull-up',
      ),
      isTrue,
    );
    expect(
      await (db.exercises.select()..where((row) => row.id.equals(wide.id)))
          .getSingleOrNull(),
      isNull,
    );
    expect(
      (await (db.exerciseSets.select()..where((row) => row.id.equals(pullSet)))
              .getSingle())
          .exerciseId,
      pull.id,
    );
    expect(
      (await (db.exerciseSets.select()..where((row) => row.id.equals(wideSet)))
              .getSingle())
          .exerciseId,
      pull.id,
    );
    expect(
      (await (db.planExercises.select()
                ..where((row) => row.id.equals(fridayPull.id)))
              .getSingle())
          .exerciseId,
      pull.id,
    );
    expect(
      await (db.planExercises.select()
            ..where((row) => row.id.equals(widePlanId)))
          .getSingleOrNull(),
      isNull,
    );

    final keptHanging =
        await (db.exercises.select()..where((row) => row.id.equals(hanging.id)))
            .getSingle();
    expect(keptHanging.name, 'Hanging leg raise');
    expect(keptHanging.catalogId, 'beinheben-haengend');
    expect(
      await (db.exercises.select()..where((row) => row.id.equals(legRaise.id)))
          .getSingleOrNull(),
      isNull,
    );
    expect(
      (await (db.exerciseSets.select()
                ..where((row) => row.id.equals(hangingSet)))
              .getSingle())
          .exerciseId,
      hanging.id,
    );
    expect(
      (await (db.exerciseSets.select()..where((row) => row.id.equals(legSet)))
              .getSingle())
          .exerciseId,
      hanging.id,
    );

    final crunches =
        await (db.exercises.select()
              ..where((row) => row.catalogId.equals('crunches')))
            .getSingle();
    expect(crunches.name, 'Crunch');
    expect(crunches.imageSource, '');
    expect(crunches.imageLicense, '');
    expect(crunches.alternatives, '[]');

    final licenses = await exerciseLicenseRows(db);
    expect(
      licenses.any(
        (row) =>
            !row.image &&
            row.source ==
                'free-exercise-db: Barbell_Bench_Press_-_Medium_Grip' &&
            row.license == 'Unlicense',
      ),
      isTrue,
    );
    expect(licenses.any((row) => row.image), isFalse);

    final stillThere =
        await (db.exercises.select()
              ..where((row) => row.id.equals(untouched.id)))
            .getSingle();
    expect(stillThere.catalogId, isNull);
    expect(stillThere.name, 'Neck curl');

    final incline =
        await (db.exercises.select()..where(
              (row) => row.catalogId.equals('schraegbankdruecken-kurzhantel'),
            ))
            .getSingle();
    expect(incline.name, 'schraegbankdruecken-kurzhantel');
    expect(incline.germanName, 'Schrägbankdrücken mit Kurzhanteln');
    expect(incline.equipment, 'Kurzhantel');
    final shoulder =
        await (db.exercises.select()
              ..where((row) => row.name.equals('Dumbbell shoulder press')))
            .getSingle();
    expect(shoulder.catalogId, 'schulterdruecken-kurzhantel');
    expect(shoulder.germanName, 'Schulterdrücken mit Kurzhanteln');

    final second = await importExerciseCatalogJson(
      db,
      raw,
      legacyMapRaw: legacyMap,
    );
    expect(second.inserted, 0);
    expect(second.updated, 0);
    expect(second.merged, 0);
    expect(second.unchanged, 294);

    final changed = raw.replaceFirst('Bankdrücken', 'Bankdrücken geändert');
    final third = await importExerciseCatalogJson(
      db,
      changed,
      legacyMapRaw: legacyMap,
    );
    expect(third.updated, 1);
    expect(third.merged, 0);
    final renamed =
        await (db.exercises.select()..where((row) => row.id.equals(before.id)))
            .getSingle();
    expect(renamed.germanName, 'Bankdrücken geändert');
    expect(renamed.id, before.id);
    expect(
      (await (db.exerciseSets.select()
                ..where((row) => row.id.equals(historyId)))
              .getSingle())
          .exerciseId,
      before.id,
    );
    expect(
      (await (db.exerciseSets.select()
                ..where((row) => row.id.equals(mediumSet)))
              .getSingle())
          .exerciseId,
      before.id,
    );
  });

  test('a later legacy name keeps the original exercise id', () async {
    const created = '''
[
  {
    "id": "bankdruecken-langhantel",
    "name_de": "Bankdrücken",
    "synonyme": ["Bench Press"],
    "kategorie": "Brust",
    "primaermuskeln": ["brust"],
    "sekundaermuskeln": [],
    "geraet": "Langhantel",
    "split": "push",
    "mechanik": "grund",
    "ausfuehrung_de": ["Platzhalter."],
    "tipps_de": [],
    "bild": "bankdruecken-langhantel.webp",
    "quelle": "placeholder",
    "lizenz": "placeholder",
    "familie": "bankdruecken",
    "bewegung": "druecken",
    "einseitig": false
  }
]
''';
    final first = await importExerciseCatalogJson(db, created);
    expect(first.inserted, 1);
    final duplicate =
        await (db.exercises.select()
              ..where((row) => row.catalogId.equals('bankdruecken-langhantel')))
            .getSingle();
    final original =
        await (db.exercises.select()
              ..where((row) => row.name.equals('Barbell bench press')))
            .getSingle();
    final historyId = await db.exerciseSets.insertOne(
      ExerciseSetsCompanion.insert(
        exerciseId: original.id,
        timestamp: DateTime(2024, 6, 1),
        reps: const Value(5),
        loadKg: const Value(100),
      ),
    );

    final linked = created.replaceFirst(
      '"lizenz": "placeholder"',
      '"lizenz": "placeholder",\n    "legacy_names": ["Barbell bench press"]',
    );
    final second = await importExerciseCatalogJson(db, linked);
    expect(second.merged, 1);

    final kept =
        await (db.exercises.select()
              ..where((row) => row.id.equals(original.id)))
            .getSingle();
    expect(kept.catalogId, 'bankdruecken-langhantel');
    expect(kept.name, 'Barbell bench press');
    expect(kept.image, 'assets/exercises/img/bankdruecken-langhantel.webp');
    expect(
      await (db.exercises.select()..where((row) => row.id.equals(duplicate.id)))
          .getSingleOrNull(),
      isNull,
    );
    expect(
      (await (db.exerciseSets.select()
                ..where((row) => row.id.equals(historyId)))
              .getSingle())
          .exerciseId,
      original.id,
    );
  });

  test('split in the catalog file is ignored', () {
    const raw = '''
[
  {
    "id": "bad-split",
    "name_de": "Falsch",
    "synonyme": [],
    "kategorie": "Brust",
    "primaermuskeln": [],
    "sekundaermuskeln": [],
    "geraet": "Langhantel",
    "split": "legs",
    "mechanik": "grund",
    "ausfuehrung_de": [],
    "tipps_de": [],
    "bild": "bad-split.webp",
    "quelle": "placeholder",
    "lizenz": "placeholder",
    "familie": "bad-split",
    "bewegung": "druecken",
    "einseitig": false
  }
]
''';
    final parsed = parseExerciseCatalog(raw);
    expect(parsed.skipped, isEmpty);
    expect(parsed.entries, hasLength(1));
    expect(parsed.entries.single.id, 'bad-split');
  });

  test('ids, images, muscles, gear and unknown fields', () {
    const valid = '''
{
  "id": "bankdruecken-langhantel",
  "name_de": "Bankdrücken",
  "synonyme": [],
  "kategorie": "Brust",
  "primaermuskeln": ["brust"],
  "sekundaermuskeln": [],
  "geraet": "Langhantel",
  "split": "push",
  "mechanik": "grund",
  "ausfuehrung_de": [],
  "tipps_de": [],
  "bild": "bankdruecken-langhantel.webp",
  "quelle": "placeholder",
  "lizenz": "placeholder",
  "familie": "bankdruecken",
  "bewegung": "druecken",
  "einseitig": false,
  "future_field": {"ok": true}
}''';
    String row(String patch) => '[$valid]'.replaceFirst(
      '"lizenz": "placeholder"',
      '"lizenz": "placeholder", $patch',
    );

    expect(parseExerciseCatalog('[$valid]').entries, hasLength(1));
    expect(
      parseExerciseCatalog(
        '[$valid]'.replaceFirst('"split": "push",', ''),
      ).entries,
      hasLength(1),
    );
    expect(
      parseExerciseCatalog(
        '[$valid]'.replaceFirst('"split": "push"', '"split": null'),
      ).entries,
      hasLength(1),
    );
    expect(parseExerciseCatalog('[$valid]').entries.single.imageSource, '');
    expect(
      parseExerciseCatalog('[$valid]').entries.single.alternatives,
      isEmpty,
    );

    expect(parseExerciseCatalog(row('"id": "Bankdruecken"')).entries, isEmpty);
    expect(
      parseExerciseCatalog(
        '[$valid]'.replaceFirst(
          '"id": "bankdruecken-langhantel"',
          '"id": "eigen-bank"',
        ),
      ).entries,
      isEmpty,
    );
    expect(
      parseExerciseCatalog(
        '[$valid]'.replaceFirst('"bewegung": "druecken"', '"bewegung": "push"'),
      ).entries,
      isEmpty,
    );
    expect(
      parseExerciseCatalog(
        '[$valid]'.replaceFirst('"familie": "bankdruecken",', ''),
      ).entries,
      isEmpty,
    );
    expect(
      parseExerciseCatalog(
        row('"position": "vorgebeugt"'),
      ).entries.single.position,
      'vorgebeugt',
    );
    expect(
      parseExerciseCatalog(
        '[$valid]'.replaceFirst(
          '"id": "bankdruecken-langhantel"',
          '"id": "bankdrücken"',
        ),
      ).entries,
      isEmpty,
    );
    expect(
      parseExerciseCatalog(
        '[$valid]'.replaceFirst(
          '"id": "bankdruecken-langhantel"',
          '"id": "bank_druecken"',
        ),
      ).entries,
      isEmpty,
    );
    expect(
      parseExerciseCatalog(
        '[$valid]'.replaceFirst(
          '"bild": "bankdruecken-langhantel.webp"',
          '"bild": "assets/exercises/img/bankdruecken-langhantel.webp"',
        ),
      ).entries,
      isEmpty,
    );
    expect(
      parseExerciseCatalog(
        '[$valid]'.replaceFirst(
          '"primaermuskeln": ["brust"]',
          '"primaermuskeln": ["chest"]',
        ),
      ).entries,
      isEmpty,
    );
    expect(
      parseExerciseCatalog(
        '[$valid]'.replaceFirst(
          '"geraet": "Langhantel"',
          '"geraet": "langhantel"',
        ),
      ).entries,
      isEmpty,
    );
    for (final gear in const [
      'Hantelscheibe',
      'Bauchroller',
      'Battle Rope',
      'Schlitten',
      'Springseil',
    ]) {
      expect(
        parseExerciseCatalog(
          '[$valid]'.replaceFirst(
            '"geraet": "Langhantel"',
            '"geraet": "$gear"',
          ),
        ).entries.single.equipment,
        gear,
      );
    }
    expect(
      parseExerciseCatalog(
        '[$valid]'.replaceFirst('"kategorie": "Brust"', '"kategorie": "Arme"'),
      ).entries,
      isEmpty,
    );
    expect(
      parseExerciseCatalog(row('"schulter_risiko": "extrem"')).entries,
      hasLength(1),
    );
    expect(
      parseExerciseCatalog(row('"schulter_risiko": "hoch"')).skipped,
      isEmpty,
    );
    expect(parseExerciseCatalog(row('"bild_quelle": 1')).entries, isEmpty);
    expect(
      parseExerciseCatalog(
        '[$valid]'.replaceFirst('"mechanik": "grund"', '"mechanik": null'),
      ).entries.single.mechanic,
      isEmpty,
    );
    expect(
      parseExerciseCatalog(
        '[$valid]'.replaceFirst('"mechanik": "grund"', '"mechanik": "legs"'),
      ).entries,
      isEmpty,
    );
    final optionalNull = parseExerciseCatalog(
      row('"bild_quelle": null, "bild_lizenz": null, "schulter_risiko": null'),
    );
    expect(optionalNull.entries, hasLength(1));
    expect(optionalNull.entries.single.imageSource, isEmpty);
    expect(optionalNull.entries.single.imageLicense, isEmpty);
    expect(
      parseExerciseCatalog(row('"alternativen": "klimmzug"')).entries,
      isEmpty,
    );
    final withAlternative = parseExerciseCatalog(
      row(
        '"alternativen": ["klimmzug"], "bild_quelle": "wiki", "bild_lizenz": "cc"',
      ),
    );
    expect(withAlternative.entries.single.alternatives, ['klimmzug']);
    expect(withAlternative.entries.single.imageSource, 'wiki');
    expect(withAlternative.entries.single.imageLicense, 'cc');
    expect(
      parseExerciseCatalog(
        row('"alternativen": []'),
      ).entries.single.alternatives,
      isEmpty,
    );
  });

  test(
    'null mechanik from the probe is stored and stays out of search',
    () async {
      final rows = _probeRows();
      expect(rows, hasLength(294));
      expect(rows.every((row) => !row.containsKey('schulter_risiko')), isTrue);
      expect(rows.any((row) => row.containsKey('alternativen')), isTrue);
      expect(
        rows
            .where((row) => row['kategorie'] == 'Cardio')
            .map((row) => row['mechanik']),
        everyElement(isNull),
      );
      final parsed = parseExerciseCatalog(jsonEncode(rows));
      expect(parsed.skipped, isEmpty);
      expect(
        parsed.entries
            .where((entry) => entry.category == 'Cardio')
            .map((entry) => entry.mechanic),
        everyElement(isEmpty),
      );
      expect(parsed.entries.first.mechanic, 'grund');

      final imported = await importExerciseCatalogJson(
        db,
        jsonEncode(rows),
        legacyMapRaw: File(
          'assets/exercises/legacy_map.json',
        ).readAsStringSync(),
      );
      expect(imported.skipped, isEmpty);
      final cardio =
          await (db.exercises.select()
                ..where((row) => row.catalogId.equals('laufband')))
              .getSingle();
      final bench =
          await (db.exercises.select()..where(
                (row) => row.catalogId.equals('bankdruecken-langhantel'),
              ))
              .getSingle();
      expect(cardio.mechanic, isNull);
      expect(bench.mechanic, 'grund');
      expect(catalogText(cardio.mechanic), isNull);
      expect(
        matchesExerciseFilters(
          name: cardio.name,
          mechanic: cardio.mechanic,
          query: '',
          mechanicFilter: 'grund',
        ),
        isFalse,
      );
      expect(cardio.kind, 'cardio');
      expect(bench.bewegung, 'druecken');
      expect(rows.every((row) => row['familie'] is String), isTrue);
      expect(rows.every((row) => row['einseitig'] is bool), isTrue);
      expect(
        rows.every((row) => !(row['id'] as String).startsWith('eigen-')),
        isTrue,
      );
      expect(
        exerciseMatchesQuery(
          name: cardio.name,
          category: cardio.categoryName,
          movement: cardio.bewegung,
          query: 'Push',
        ),
        isFalse,
      );
      expect(
        exerciseMatchesQuery(
          name: bench.name,
          category: bench.categoryName,
          muscle: bench.muscle,
          primaryMuscles: bench.primaryMuscles,
          movement: bench.bewegung,
          query: 'Push',
        ),
        isTrue,
      );
      expect(
        exerciseMatchesQuery(
          name: 'Latziehen',
          category: 'Rücken',
          primaryMuscles: '["latissimus"]',
          query: 'Pull',
        ),
        isFalse,
      );
      expect(
        exerciseMatchesQuery(
          name: 'Face Pulls',
          category: 'Schultern',
          primaryMuscles: '["schulter_hinten"]',
          movement: 'ziehen',
          query: 'Pull',
        ),
        isTrue,
      );
      expect(
        exerciseMatchesQuery(
          name: 'Kniebeuge',
          category: 'Beine',
          primaryMuscles: '["quadrizeps","gesaess"]',
          query: 'Beine',
        ),
        isTrue,
      );
      expect(
        exerciseMatchesQuery(
          name: 'Crunch',
          category: 'Bauch',
          primaryMuscles: '["bauch_gerade"]',
          query: 'Pull',
        ),
        isFalse,
      );
      expect(
        exerciseMatchesQuery(
          name: cardio.name,
          germanName: cardio.germanName,
          mechanic: cardio.mechanic,
          query: 'null',
        ),
        isFalse,
      );
    },
  );

  testWidgets('detail page and filters hide a null mechanic', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    final logged = <FlutterErrorDetails>[];
    final previous = FlutterError.onError;
    FlutterError.onError = logged.add;
    addTearDown(() => FlutterError.onError = previous);
    final rows = _probeRows();
    await importExerciseCatalogJson(
      harness.database,
      jsonEncode(rows),
      legacyMapRaw: File('assets/exercises/legacy_map.json').readAsStringSync(),
    );
    final cardio =
        await (harness.database.exercises.select()
              ..where((row) => row.catalogId.equals('crosstrainer')))
            .getSingle();
    final bench =
        await (harness.database.exercises.select()
              ..where((row) => row.catalogId.equals('bankdruecken-langhantel')))
            .getSingle();

    await harness.pump(tester, ExerciseDetailPage(exercise: cardio));
    await tester.pump();
    expect(find.textContaining('Mechanic'), findsNothing);
    expect(find.textContaining('null'), findsNothing);

    await harness.pump(tester, ExerciseDetailPage(exercise: bench));
    await tester.pump();
    expect(find.text('Mechanic: Compound'), findsOneWidget);
    expect(find.textContaining('null'), findsNothing);
    expect(bench.image, 'assets/exercises/img/bankdruecken-langhantel.webp');
    expect(File(bench.image!).existsSync(), isFalse);
    expect(bundledExerciseImages, isNot(contains(bench.image)));
    expect(find.byType(ExerciseImagePlaceholder), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(logged, isEmpty);

    await harness.pump(tester, const Scaffold(body: ExercisesPage()));
    await tester.pumpAndSettle(
      const Duration(milliseconds: 50),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 3),
    );
    expect(find.text('null'), findsNothing);
    expect(find.byType(ExerciseImagePlaceholder), findsWidgets);
    expect(tester.takeException(), isNull);
    expect(logged, isEmpty);
    final chips = find.descendant(
      of: find.byKey(const Key('exercise-filters')),
      matching: find.byType(Scrollable),
    );
    for (final gear in const [
      'Hantelscheibe',
      'Bauchroller',
      'Battle Rope',
      'Schlitten',
      'Springseil',
    ]) {
      await tester.scrollUntilVisible(find.text(gear), 200, scrollable: chips);
      expect(find.text(gear), findsOneWidget);
    }
    await tester.scrollUntilVisible(
      find.text('Compound'),
      400,
      scrollable: chips,
    );
    expect(find.text('Compound'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Isolation'),
      400,
      scrollable: chips,
    );
    expect(find.text('Isolation'), findsOneWidget);
    expect(find.text('null'), findsNothing);
  });

  test(
    'flexify mapping moves seed names and keeps trained suggestions',
    () async {
      final mapping = File(
        'assets/exercises/flexify_mapping.json',
      ).readAsStringSync();
      final map = parseFlexifyMapping(mapping);
      final catalogIds = _probeRows().map((row) => row['id']).toSet();
      final rawMap = jsonDecode(mapping) as Map;
      expect(rawMap.length, 294);
      expect(catalogIds, rawMap.keys.toSet());
      expect(map.length, 275);
      final suggestions = parseFlexifySuggestions(mapping);
      expect(suggestions, hasLength(100));
      final ohneRaw =
          jsonDecode(
                File(
                  'assets/exercises/flexify_ohne_ziel.json',
                ).readAsStringSync(),
              )
              as Map;
      expect(ohneRaw['anzahl_seed'], 920);
      final eintraege = ohneRaw['eintraege'] as List;
      expect(eintraege, hasLength(278));
      expect((eintraege.first as Map)['seed_name'], isA<String>());
      final ohne = parseFlexifyOhneZiel(
        File('assets/exercises/flexify_ohne_ziel.json').readAsStringSync(),
      );
      expect(ohne, hasLength(278));
      expect(ohne, contains(normalizedExerciseName('Neck curl')));
      expect(ohne, contains(normalizedExerciseName("90/90 Hamstring")));
      var seedNames = 0;
      var suggestedNames = 0;
      for (final value in rawMap.values) {
        final row = Map<String, dynamic>.from(value as Map);
        seedNames += (row['seed_namen'] as List).length;
        suggestedNames +=
            (row['aussortiert_naechste_entsprechung'] as List).length;
      }
      expect(seedNames, 542);
      expect(suggestedNames, 100);
      expect(seedNames + suggestedNames + ohne.length, 920);
      expect(map['bankdruecken-langhantel'], contains('Barbell bench press'));
      expect(map['bankdruecken-langhantel'], isNot(contains('Board Press')));
      expect(
        suggestions[normalizedExerciseName('Board Press')],
        'bankdruecken-langhantel',
      );
      expect(parseFlexifyMapping('{'), isEmpty);
      expect(parseFlexifyMapping('[]'), isEmpty);
      expect(parseFlexifySuggestions('{'), isEmpty);
      expect(parseFlexifySuggestions(null), isEmpty);
      expect(
        parseFlexifyMapping(
          '{"Bad Id": {"seed_namen": ["X"]}, "dips": {"seed_namen": ["Triceps dip", 1, ""], "aussortiert_naechste_entsprechung": ["Bench Dips"], "note": true}, "plank": []}',
        ),
        {
          'dips': ['Triceps dip'],
        },
      );
      expect(
        parseFlexifySuggestions(
          '{"dips": {"aussortiert_naechste_entsprechung": ["Bench Dips", ""]}}',
        ),
        {'bench dips': 'dips'},
      );

      final bench =
          await (db.exercises.select()
                ..where((row) => row.name.equals('Barbell bench press')))
              .getSingle();
      final boardId = await db.exercises.insertOne(
        ExercisesCompanion.insert(
          name: 'Board Press',
          kind: 'strength',
          displayUnit: 'kg',
        ),
      );
      final boardSet = await db.exerciseSets.insertOne(
        ExerciseSetsCompanion.insert(
          exerciseId: boardId,
          timestamp: DateTime(2024, 7, 1),
          reps: const Value(4),
          loadKg: const Value(100),
        ),
      );
      final arnold =
          await (db.exercises.select()
                ..where((row) => row.name.equals('Arnold press')))
              .getSingle();
      final neck =
          await (db.exercises.select()
                ..where((row) => row.name.equals('Neck curl')))
              .getSingle();

      final imported = await importExerciseCatalogJson(
        db,
        File('assets/exercises/exercises_de.json').readAsStringSync(),
        flexifyMapRaw: mapping,
        ohneZielRaw: File(
          'assets/exercises/flexify_ohne_ziel.json',
        ).readAsStringSync(),
      );
      expect(imported.skipped, isEmpty);
      final boardAfter =
          await (db.exercises.select()..where((row) => row.id.equals(boardId)))
              .getSingle();
      expect(boardAfter.name, 'Board Press');
      expect(boardAfter.catalogId, 'eigen-board-press');
      expect(isCustomExercise(boardAfter), isTrue);
      expect(boardAfter.alternatives, '["bankdruecken-langhantel"]');
      expect(
        (await (db.exerciseSets.select()
                  ..where((row) => row.id.equals(boardSet)))
                .getSingle())
            .exerciseId,
        boardId,
      );
      final benchAfter =
          await (db.exercises.select()..where((row) => row.id.equals(bench.id)))
              .getSingle();
      expect(benchAfter.catalogId, 'bankdruecken-langhantel');
      expect(benchAfter.name, 'Barbell bench press');
      expect(
        await (db.exerciseSets.select()
              ..where((row) => row.exerciseId.equals(bench.id)))
            .get(),
        isEmpty,
      );
      expect(
        await (db.exercises.select()
              ..where((row) => row.name.equals('Pin Presses')))
            .getSingleOrNull(),
        isNull,
      );
      final arnoldAfter =
          await (db.exercises.select()
                ..where((row) => row.id.equals(arnold.id)))
              .getSingle();
      expect(arnoldAfter.name, 'Arnold press');
      expect(arnoldAfter.catalogId, 'arnold-press');
      final neckAfter =
          await (db.exercises.select()..where((row) => row.id.equals(neck.id)))
              .getSingle();
      expect(neckAfter.name, 'Neck curl');
      expect(neckAfter.catalogId, isNull);
    },
  );

  test(
    'trained ohne-ziel seeds become custom exercises and keep records',
    () async {
      final raw = File('assets/exercises/exercises_de.json').readAsStringSync();
      final mapping = File(
        'assets/exercises/flexify_mapping.json',
      ).readAsStringSync();
      final ohneZielRaw = File(
        'assets/exercises/flexify_ohne_ziel.json',
      ).readAsStringSync();
      final neck =
          await (db.exercises.select()
                ..where((row) => row.name.equals('Neck curl')))
              .getSingle();
      final light = await db.exerciseSets.insertOne(
        ExerciseSetsCompanion.insert(
          exerciseId: neck.id,
          timestamp: DateTime(2024, 9, 1),
          reps: const Value(12),
          loadKg: const Value(10),
        ),
      );
      final heavy = await db.exerciseSets.insertOne(
        ExerciseSetsCompanion.insert(
          exerciseId: neck.id,
          timestamp: DateTime(2024, 9, 8),
          reps: const Value(6),
          loadKg: const Value(25),
        ),
      );
      final planId = await db.plans.insertOne(
        PlansCompanion.insert(days: '', title: const Value('Nacken')),
      );
      final planExerciseId = await db.planExercises.insertOne(
        PlanExercisesCompanion.insert(
          enabled: true,
          exerciseId: neck.id,
          planId: planId,
        ),
      );
      final idleId = await db.exercises.insertOne(
        ExercisesCompanion.insert(
          name: '90/90 Hamstring',
          kind: 'strength',
          displayUnit: 'kg',
        ),
      );

      final imported = await importExerciseCatalogJson(
        db,
        raw,
        flexifyMapRaw: mapping,
        ohneZielRaw: ohneZielRaw,
      );
      expect(imported.skipped, isEmpty);

      final kept =
          await (db.exercises.select()..where((row) => row.id.equals(neck.id)))
              .getSingle();
      expect(kept.name, 'Neck curl');
      expect(kept.catalogId, 'eigen-neck-curl');
      expect(kept.germanName, 'Neck curl');
      expect(kept.archived, isFalse);
      expect(isCustomExercise(kept), isTrue);
      expect(
        exerciseMatchesQuery(
          name: kept.name,
          germanName: kept.germanName,
          query: 'Neck',
        ),
        isTrue,
      );
      final sets =
          await (db.exerciseSets.select()
                ..where((row) => row.exerciseId.equals(neck.id)))
              .get();
      expect(sets, hasLength(2));
      expect(sets.map((set) => set.id).toSet(), {light, heavy});
      final record = sets.reduce(
        (left, right) =>
            (left.loadKg ?? 0) >= (right.loadKg ?? 0) ? left : right,
      );
      expect(record.id, heavy);
      expect(record.loadKg, 25);
      expect(record.reps, 6);
      final planExercise =
          await (db.planExercises.select()
                ..where((row) => row.id.equals(planExerciseId)))
              .getSingle();
      expect(planExercise.exerciseId, neck.id);

      final idle =
          await (db.exercises.select()..where((row) => row.id.equals(idleId)))
              .getSingle();
      expect(idle.name, '90/90 Hamstring');
      expect(idle.catalogId, isNull);
      expect(
        await (db.exercises.select()
              ..where((row) => row.catalogId.equals('eigen-90-90-hamstring')))
            .getSingleOrNull(),
        isNull,
      );

      final again = await importExerciseCatalogJson(
        db,
        raw,
        flexifyMapRaw: mapping,
        ohneZielRaw: ohneZielRaw,
      );
      expect(again.skipped, isEmpty);
      final still =
          await (db.exercises.select()..where((row) => row.id.equals(neck.id)))
              .getSingle();
      expect(still.catalogId, 'eigen-neck-curl');
      expect(still.name, 'Neck curl');
      expect(
        await (db.exerciseSets.select()
              ..where((row) => row.exerciseId.equals(neck.id)))
            .get(),
        hasLength(2),
      );
    },
  );

  test('flexify names match apostrophes only through the mapping', () async {
    expect(
      normalizedExerciseName("  Farmer's Walk "),
      normalizedExerciseName("Farmer\u2019s Walk"),
    );
    expect(normalizedExerciseName("Farmer\\'s Walk"), "farmer's walk");
    expect(
      parseFlexifyOhneZiel(
        File('assets/exercises/flexify_ohne_ziel.json').readAsStringSync(),
      ),
      hasLength(278),
    );
    expect(parseFlexifyOhneZiel(null), isEmpty);
    expect(parseFlexifyOhneZiel('{'), isEmpty);

    String row({
      required String id,
      required String name,
      required String category,
      required String movement,
      required String gear,
      String? mechanic,
    }) {
      return jsonEncode({
        'id': id,
        'name_de': name,
        'synonyme': <String>[],
        'kategorie': category,
        'primaermuskeln': category == 'Cardio' ? <String>[] : ['brust'],
        'sekundaermuskeln': <String>[],
        'geraet': gear,
        'mechanik': mechanic,
        'ausfuehrung_de': <String>[],
        'tipps_de': <String>[],
        'bild': '$id.webp',
        'quelle': 'placeholder',
        'lizenz': 'placeholder',
        'familie': id,
        'bewegung': movement,
        'einseitig': false,
      });
    }

    final straightId = await db.exercises.insertOne(
      ExercisesCompanion.insert(
        name: "Farmer's Walk",
        kind: 'strength',
        displayUnit: 'kg',
      ),
    );
    final curlyId = await db.exercises.insertOne(
      ExercisesCompanion.insert(
        name: 'Farmer\u2019s Walk',
        kind: 'strength',
        displayUnit: 'kg',
      ),
    );
    final escapedId = await db.exercises.insertOne(
      ExercisesCompanion.insert(
        name: " Farmer\\'s Carry ",
        kind: 'strength',
        displayUnit: 'kg',
      ),
    );
    final straightSet = await db.exerciseSets.insertOne(
      ExerciseSetsCompanion.insert(
        exerciseId: straightId,
        timestamp: DateTime(2024, 8, 1),
        reps: const Value(8),
        loadKg: const Value(40),
      ),
    );
    final curlySet = await db.exerciseSets.insertOne(
      ExerciseSetsCompanion.insert(
        exerciseId: curlyId,
        timestamp: DateTime(2024, 8, 2),
        reps: const Value(6),
        loadKg: const Value(36),
      ),
    );
    final escapedSet = await db.exerciseSets.insertOne(
      ExerciseSetsCompanion.insert(
        exerciseId: escapedId,
        timestamp: DateTime(2024, 8, 3),
        reps: const Value(4),
        loadKg: const Value(32),
      ),
    );
    final airBikeId = await db.exercises.insertOne(
      ExercisesCompanion.insert(
        name: 'Air Bike',
        kind: 'strength',
        displayUnit: 'kg',
      ),
    );
    final airBikeSet = await db.exerciseSets.insertOne(
      ExerciseSetsCompanion.insert(
        exerciseId: airBikeId,
        timestamp: DateTime(2024, 8, 4),
        reps: const Value(20),
      ),
    );
    final sameId = await db.exercises.insertOne(
      ExercisesCompanion.insert(
        name: 'Air-Bike',
        kind: 'cardio',
        displayUnit: 'km',
      ),
    );
    final sameSet = await db.exerciseSets.insertOne(
      ExerciseSetsCompanion.insert(
        exerciseId: sameId,
        timestamp: DateTime(2024, 8, 5),
        reps: const Value(12),
      ),
    );
    final keptId = await db.exercises.insertOne(
      ExercisesCompanion.insert(
        name: 'Shoulder Press',
        kind: 'strength',
        displayUnit: 'kg',
      ),
    );
    final apostropheKeptId = await db.exercises.insertOne(
      ExercisesCompanion.insert(
        name: "Shoulder's Press",
        kind: 'strength',
        displayUnit: 'kg',
      ),
    );
    final keptSet = await db.exerciseSets.insertOne(
      ExerciseSetsCompanion.insert(
        exerciseId: keptId,
        timestamp: DateTime(2024, 8, 6),
        reps: const Value(10),
        loadKg: const Value(20),
      ),
    );

    final imported = await importExerciseCatalogJson(
      db,
      '[${row(id: 'bicycle-crunches', name: 'Bicycle Crunches', category: 'Bauch', movement: 'rumpf', gear: 'Körpergewicht', mechanic: 'isolation')},${row(id: 'farmers-walk', name: 'Farmers Walk', category: 'Beine', movement: 'beine_huefte', gear: 'Langhantel', mechanic: 'grund')},${row(id: 'air-bike', name: 'Air Bike', category: 'Cardio', movement: 'cardio', gear: 'Cardiogerät')}]',
      flexifyMapRaw: jsonEncode({
        'bicycle-crunches': {
          'seed_namen': ['Air Bike'],
          'aussortiert_naechste_entsprechung': <String>[],
        },
        'farmers-walk': {
          'seed_namen': ["Farmer's Walk"],
          'aussortiert_naechste_entsprechung': ["Farmer's Carry"],
        },
        'air-bike': {
          'seed_namen': ['Shoulder Press', "Shoulder's Press"],
          'aussortiert_naechste_entsprechung': <String>[],
        },
      }),
      ohneZielRaw: jsonEncode(['Shoulder Press', ' Shoulder\u2019s Press ']),
    );

    expect(imported.skipped, isEmpty);
    final farmer =
        await (db.exercises.select()
              ..where((exercise) => exercise.id.equals(straightId)))
            .getSingle();
    expect(farmer.catalogId, 'farmers-walk');
    expect(farmer.name, "Farmer's Walk");
    expect(
      await (db.exercises.select()
            ..where((exercise) => exercise.id.equals(curlyId)))
          .getSingleOrNull(),
      isNull,
    );
    final carry =
        await (db.exercises.select()
              ..where((exercise) => exercise.id.equals(escapedId)))
            .getSingle();
    expect(carry.name, " Farmer\\'s Carry ");
    expect(carry.catalogId, 'eigen-farmer-s-carry');
    expect(carry.alternatives, '["farmers-walk"]');
    expect(
      (await (db.exerciseSets.select()
                ..where((row) => row.id.equals(escapedSet)))
              .getSingle())
          .exerciseId,
      escapedId,
    );
    for (final setId in [straightSet, curlySet]) {
      expect(
        (await (db.exerciseSets.select()..where((row) => row.id.equals(setId)))
                .getSingle())
            .exerciseId,
        straightId,
      );
    }

    final crunch =
        await (db.exercises.select()
              ..where((exercise) => exercise.id.equals(airBikeId)))
            .getSingle();
    expect(crunch.name, 'Air Bike');
    expect(crunch.catalogId, 'bicycle-crunches');
    expect(
      (await (db.exerciseSets.select()
                ..where((row) => row.id.equals(airBikeSet)))
              .getSingle())
          .exerciseId,
      airBikeId,
    );
    final untouched =
        await (db.exercises.select()
              ..where((exercise) => exercise.id.equals(sameId)))
            .getSingle();
    expect(untouched.name, 'Air-Bike');
    expect(untouched.catalogId, isNull);
    expect(
      (await (db.exerciseSets.select()..where((row) => row.id.equals(sameSet)))
              .getSingle())
          .exerciseId,
      sameId,
    );
    final cardio =
        await (db.exercises.select()
              ..where((exercise) => exercise.catalogId.equals('air-bike')))
            .getSingle();
    expect(cardio.name, 'air-bike');
    expect(cardio.id, isNot(sameId));
    expect(cardio.id, isNot(airBikeId));
    expect(cardio.id, isNot(keptId));
    final kept =
        await (db.exercises.select()
              ..where((exercise) => exercise.id.equals(keptId)))
            .getSingle();
    expect(kept.name, 'Shoulder Press');
    expect(kept.catalogId, 'eigen-shoulder-press');
    expect(isCustomExercise(kept), isTrue);
    final apostropheKept =
        await (db.exercises.select()
              ..where((exercise) => exercise.id.equals(apostropheKeptId)))
            .getSingle();
    expect(apostropheKept.name, "Shoulder's Press");
    expect(apostropheKept.catalogId, isNull);
    expect(
      (await (db.exerciseSets.select()..where((row) => row.id.equals(keptSet)))
              .getSingle())
          .exerciseId,
      keptId,
    );
  });

  test('search ranks exact names and synonyms above substrings', () async {
    final raw = File('assets/exercises/exercises_de.json').readAsStringSync();
    final decoded = jsonDecode(raw) as List;
    var synonyms = 0;
    for (final row in decoded) {
      synonyms += ((row as Map)['synonyme'] as List).length;
    }
    expect(synonyms, 2248);
    final imported = await importExerciseCatalogJson(db, raw);
    expect(imported.skipped, isEmpty);
    final rows = await db.exercises.select().get();

    List<String> ranked(String query) {
      final matches =
          rows
              .where(
                (exercise) => exerciseMatchesQuery(
                  name: exercise.name,
                  germanName: exercise.germanName,
                  aliases: exercise.aliases,
                  movement: exercise.bewegung,
                  category: exercise.categoryName,
                  query: query,
                ),
              )
              .toList()
            ..sort(
              (a, b) => compareExerciseSearch(
                query: query,
                leftName: a.name,
                leftGermanName: a.germanName,
                leftAliases: a.aliases,
                rightName: b.name,
                rightGermanName: b.germanName,
                rightAliases: b.aliases,
              ),
            );
      return [
        for (final exercise in matches)
          if ((exercise.catalogId ?? '').isNotEmpty) exercise.catalogId!,
      ];
    }

    for (final query in [
      'Lat Pulldown',
      'lat pulldown',
      'Pulldown',
      'Latzug',
      'Latziehen',
    ]) {
      expect(ranked(query).first, 'latziehen-breit', reason: query);
    }
    expect(ranked('straight arm pulldown').first, 'ueberzuege-kabel');

    expect(ranked('Lat Pulldown').take(5), [
      'latziehen-breit',
      'latziehen-eng',
      'latziehen-einarmig',
      'ueberzuege-kabel',
      'latziehen-untergriff',
    ]);
    final pulldown = ranked('Pulldown');
    expect(pulldown.take(5), [
      'latziehen-breit',
      'ueberzuege-kabel',
      'latziehen-eng',
      'latziehen-einarmig',
      'latziehen-untergriff',
    ]);
    expect(ranked('Latzug').take(5), [
      'latziehen-breit',
      'latziehen-eng',
      'latziehen-untergriff',
      'latziehen-nacken',
      'latziehen-maschine',
    ]);
    final cable = pulldown.indexOf('ueberzuege-kabel');
    final latziehen = [
      for (var index = 0; index < pulldown.length; index++)
        if (pulldown[index].startsWith('latziehen-')) index,
    ];
    expect(cable, greaterThan(pulldown.indexOf('latziehen-breit')));
    expect(latziehen, contains(cable - 1));
    expect(pulldown.skip(cable + 1), contains('latziehen-eng'));

    expect(
      exerciseSearchRank(
        name: 'eigen-lat-pulldown',
        germanName: 'Lat Pulldown',
        query: 'lat pulldown',
      ),
      1,
    );
    expect(
      compareExerciseSearch(
        query: 'lat pulldown',
        leftName: 'eigen-lat-pulldown',
        leftGermanName: 'Lat Pulldown',
        rightName: 'latziehen-breit',
        rightGermanName: 'Latziehen',
        rightAliases: 'Lat Pulldown',
      ),
      lessThan(0),
    );
    expect(exerciseSearchRank(name: 'Überzüge', query: 'uberzuge'), 1);
  });

  test('legacy map entries can be extended and bad ones are skipped', () {
    expect(parseLegacyNameMap('{'), isEmpty);
    expect(parseLegacyNameMap('[]'), isEmpty);
    expect(
      parseLegacyNameMap(
        '{"not an id": ["X"], "klimmzuege": ["Pull-up", 1, ""], "dips": "nope", "plank": ["Plank"]}',
      ),
      {
        'klimmzuege': ['Pull-up'],
        'plank': ['Plank'],
      },
    );
  });
}
