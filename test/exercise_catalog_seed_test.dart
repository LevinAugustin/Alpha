import 'package:drift/drift.dart';
import 'package:flexify/database/catalog_seed.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock_tests.dart';

void main() {
  setUp(() => db = testDb());

  test('catalog keeps existing exercise ids and matches aliases', () async {
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

    await seedExerciseCatalog(db);

    final after =
        await (db.exercises.select()..where((row) => row.id.equals(before.id)))
            .getSingle();
    expect(after.name, 'Barbell bench press');
    expect(after.germanName, 'Bankdrücken');
    expect(after.muscle, 'Brust');
    expect(
      exerciseMatchesQuery(
        name: after.name,
        germanName: after.germanName,
        aliases: after.aliases,
        query: 'Flachbank',
      ),
      isTrue,
    );
    expect(
      exerciseMatchesQuery(
        name: after.name,
        germanName: after.germanName,
        aliases: after.aliases,
        query: 'Bench Press',
      ),
      isTrue,
    );
    expect(
      exerciseMatchesQuery(
        name: after.name,
        germanName: after.germanName,
        aliases: after.aliases,
        query: 'Bankdrücken',
      ),
      isTrue,
    );

    final history =
        await (db.exerciseSets.select()
              ..where((row) => row.id.equals(historyId)))
            .getSingle();
    expect(history.exerciseId, before.id);
    expect(await db.exercises.count().getSingle(), greaterThan(400));
  });
}
