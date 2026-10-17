import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flexify/database/catalog_seed.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/database/exercise_de_catalog.dart';
import 'package:flexify/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock_tests.dart';

void main() {
  setUp(() => db = testDb());

  test('catalog keeps existing exercise ids and reapplies the file', () async {
    final raw = File('assets/exercises/exercises_de.json').readAsStringSync();
    final legacyMap = File(
      'assets/exercises/legacy_map.json',
    ).readAsStringSync();
    final parsed = parseExerciseCatalog(raw);
    expect(parsed.skipped, isEmpty);
    expect(parsed.entries, hasLength(30));
    expect(parsed.entries.first.imageSource, isEmpty);
    expect(parsed.entries.first.imageLicense, isEmpty);
    expect(parsed.entries.last.id, 'crosstrainer');
    final map = parseLegacyNameMap(legacyMap);
    expect(map.keys, parsed.entries.map((entry) => entry.id));

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
    expect(first.inserted, 11);
    expect(first.updated, 19);
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
    expect(after.schulterRisiko, 'mittel');
    expect(after.split, 'push');
    expect(
      after.catalogSource,
      'free-exercise-db: Barbell_Bench_Press_-_Medium_Grip',
    );
    expect(after.catalogLicense, 'Unlicense');
    expect(after.imageSource, '');
    expect(after.imageLicense, '');
    expect(
      after.alternatives,
      '["schraegbankdruecken-multipresse","butterfly-maschine","dips"]',
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
    expect(crunches.alternatives, '["plank","beinheben-haengend"]');
    expect(crunches.schulterRisiko, 'niedrig');

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

    final second = await importExerciseCatalogJson(
      db,
      raw,
      legacyMapRaw: legacyMap,
    );
    expect(second.inserted, 0);
    expect(second.updated, 0);
    expect(second.merged, 0);
    expect(second.unchanged, 30);

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
    "lizenz": "placeholder"
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

  test('invalid catalog rows are skipped', () async {
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
    "lizenz": "placeholder"
  }
]
''';
    final parsed = parseExerciseCatalog(raw);
    expect(parsed.entries, isEmpty);
    expect(parsed.skipped, isNotEmpty);
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
  "future_field": {"ok": true}
}''';
    String row(String patch) => '[$valid]'.replaceFirst(
      '"lizenz": "placeholder"',
      '"lizenz": "placeholder", $patch',
    );

    expect(parseExerciseCatalog('[$valid]').entries, hasLength(1));
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
    expect(
      parseExerciseCatalog(
        '[$valid]'.replaceFirst('"kategorie": "Brust"', '"kategorie": "Arme"'),
      ).entries,
      isEmpty,
    );
    expect(
      parseExerciseCatalog(row('"schulter_risiko": "extrem"')).entries,
      isEmpty,
    );
    expect(
      parseExerciseCatalog(
        row('"schulter_risiko": "hoch"'),
      ).entries.single.shoulderRisk,
      'hoch',
    );
    expect(parseExerciseCatalog(row('"bild_quelle": 1')).entries, isEmpty);
    final optionalNull = parseExerciseCatalog(
      row('"bild_quelle": null, "bild_lizenz": null, "schulter_risiko": null'),
    );
    expect(optionalNull.entries, hasLength(1));
    expect(optionalNull.entries.single.imageSource, isEmpty);
    expect(optionalNull.entries.single.imageLicense, isEmpty);
    expect(optionalNull.entries.single.shoulderRisk, isEmpty);
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
