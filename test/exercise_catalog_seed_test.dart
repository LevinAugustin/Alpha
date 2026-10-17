import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flexify/database/database.dart';
import 'package:flexify/database/exercise_de_catalog.dart';
import 'package:flexify/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock_tests.dart';

void main() {
  setUp(() => db = testDb());

  test('catalog keeps existing exercise ids and reapplies the file', () async {
    final raw = File('assets/exercises/exercises_de.json').readAsStringSync();
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
    final untouched =
        await (db.exercises.select()
              ..where((row) => row.name.equals('Neck curl')))
            .getSingle();

    final first = await importExerciseCatalogJson(db, raw);
    expect(first.skipped, isEmpty);
    expect(first.inserted, 2);
    expect(first.merged, 0);

    final after =
        await (db.exercises.select()..where((row) => row.id.equals(before.id)))
            .getSingle();
    expect(after.name, 'Barbell bench press');
    expect(after.catalogId, 'bankdruecken-langhantel');
    expect(after.germanName, 'Bankdrücken');
    expect(after.muscle, 'Brust');
    expect(after.equipment, 'Langhantel');
    expect(after.primaryMuscles, '["brust","brust_oben"]');
    expect(after.secondaryMuscles, '["trizeps","schulter_vorne"]');
    expect(after.schulterRisiko, 'mittel');
    expect(after.split, 'push');
    expect(after.catalogSource, 'placeholder');
    expect(after.catalogLicense, 'placeholder');
    expect(after.imageSource, 'placeholder-bild');
    expect(after.imageLicense, 'placeholder-bildlizenz');
    expect(after.alternatives, '["bankdruecken-multipresse"]');
    expect(after.image, 'assets/exercises/img/bankdruecken-langhantel.webp');

    final crunch =
        await (db.exercises.select()
              ..where((row) => row.catalogId.equals('crunch')))
            .getSingle();
    expect(crunch.imageSource, '');
    expect(crunch.imageLicense, '');
    expect(crunch.alternatives, '[]');
    expect(crunch.schulterRisiko, isNull);

    final licenses = await exerciseLicenseRows(db);
    expect(
      licenses.any(
        (row) =>
            !row.image &&
            row.source == 'placeholder' &&
            row.license == 'placeholder',
      ),
      isTrue,
    );
    expect(
      licenses.any(
        (row) =>
            row.image &&
            row.source == 'placeholder-bild' &&
            row.license == 'placeholder-bildlizenz',
      ),
      isTrue,
    );

    final history =
        await (db.exerciseSets.select()
              ..where((row) => row.id.equals(historyId)))
            .getSingle();
    expect(history.exerciseId, before.id);

    final stillThere =
        await (db.exercises.select()
              ..where((row) => row.id.equals(untouched.id)))
            .getSingle();
    expect(stillThere.catalogId, isNull);
    expect(stillThere.name, 'Neck curl');

    final second = await importExerciseCatalogJson(db, raw);
    expect(second.inserted, 0);
    expect(second.updated, 0);
    expect(second.unchanged, 20);

    final changed = raw.replaceFirst('Bankdrücken', 'Bankdrücken geändert');
    final third = await importExerciseCatalogJson(db, changed);
    expect(third.updated, 1);
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
}
