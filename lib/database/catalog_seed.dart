import 'package:drift/drift.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/database/exercise_seed.dart';

final _exerciseKeyPattern = RegExp(r'[^a-z0-9äöüß+ ]');
final _spacePattern = RegExp(r'\s+');

String normalizeExerciseKey(String value) {
  return value
      .toLowerCase()
      .replaceAll('-', ' ')
      .replaceAll(_exerciseKeyPattern, ' ')
      .replaceAll(_spacePattern, ' ')
      .trim();
}

const _searchGroups = <List<String>>[
  [
    'push',
    'brust',
    'schulter',
    'schultern',
    'trizeps',
    'chest',
    'shoulder',
    'triceps',
  ],
  ['pull', 'rücken', 'ruecken', 'bizeps', 'lat', 'back', 'biceps'],
  ['beine', 'legs', 'quad', 'oberschenkel', 'beinbeuger', 'gesäß'],
  ['multipresse', 'smith machine', 'smith'],
  ['kabelzug', 'kabelturm', 'cable', 'kabel'],
  ['langhantel', 'barbell'],
  ['kurzhantel', 'dumbbell'],
  ['körpergewicht', 'koerpergewicht', 'bodyweight'],
  ['maschine', 'machine'],
];

bool exerciseMatchesQuery({
  required String name,
  String? germanName,
  String? aliases,
  required String query,
}) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return true;
  final haystack = '$name ${germanName ?? ''} ${aliases ?? ''}'.toLowerCase();
  if (_containsTerm(haystack, needle)) return true;
  for (final group in _searchGroups) {
    final asked =
        group.contains(needle) ||
        group.any((word) => word.length >= 5 && needle.contains(word));
    if (!asked) continue;
    if (group.any((word) => _containsTerm(haystack, word))) return true;
  }
  return false;
}

bool _containsTerm(String haystack, String word) {
  if (word.length >= 5) return haystack.contains(word);
  return RegExp('\\b${RegExp.escape(word)}\\b').hasMatch(haystack);
}

Future<void> seedExerciseCatalog(AppDatabase database) async {
  final existing = await database.select(database.exercises).get();
  final byKey = <String, Exercise>{
    for (final exercise in existing)
      normalizeExerciseKey(exercise.name): exercise,
  };

  final missing = <ExerciseSeed>[];
  var needsLabels = false;
  for (final seed in exerciseCatalog) {
    final current = byKey[normalizeExerciseKey(seed.name)];
    if (current == null) {
      missing.add(seed);
      continue;
    }
    if ((current.germanName ?? '').isEmpty || (current.muscle ?? '').isEmpty) {
      needsLabels = true;
    }
  }
  if (missing.isEmpty && !needsLabels) return;

  final categoryIds = {
    for (final category in await database.select(database.categories).get())
      category.name: category.id,
  };

  Future<int> categoryIdFor(String name) async {
    final known = categoryIds[name];
    if (known != null) return known;
    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(name: name),
          mode: InsertMode.insertOrIgnore,
        );
    final id = (await (database.select(
      database.categories,
    )..where((row) => row.name.equals(name))).getSingle()).id;
    categoryIds[name] = id;
    return id;
  }

  await database.transaction(() async {
    for (final seed in exerciseCatalog) {
      final current = byKey[normalizeExerciseKey(seed.name)];
      if (current == null) continue;
      final germanEmpty = (current.germanName ?? '').isEmpty;
      final muscleEmpty = (current.muscle ?? '').isEmpty;
      if (!germanEmpty && !muscleEmpty) continue;
      await (database.update(
        database.exercises,
      )..where((row) => row.id.equals(current.id))).write(
        ExercisesCompanion(
          germanName: Value(seed.germanName),
          aliases: muscleEmpty ? Value(seed.aliases) : const Value.absent(),
          muscle: muscleEmpty ? Value(seed.muscle) : const Value.absent(),
        ),
      );
    }

    final rows = <ExercisesCompanion>[];
    for (final seed in missing) {
      rows.add(
        ExercisesCompanion.insert(
          name: seed.name,
          kind: seed.cardio ? 'cardio' : 'strength',
          displayUnit: seed.cardio ? 'km' : 'kg',
          categoryId: Value(await categoryIdFor(seed.category)),
          germanName: Value(seed.germanName),
          aliases: Value(seed.aliases),
          muscle: Value(seed.muscle),
        ),
      );
    }
    if (rows.isEmpty) return;
    await database.batch((batch) {
      batch.insertAll(
        database.exercises,
        rows,
        mode: InsertMode.insertOrIgnore,
      );
    });
  });
}
