import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flexify/database/catalog_seed.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/database/defaults.dart';
import 'package:flexify/exercise_keys.dart';
import 'package:flexify/import/hevy_import.dart';

const customExercisePrefix = 'eigen-';

bool isCustomExercise(Exercise exercise) {
  final id = (exercise.catalogId ?? '').trim();
  if (id.startsWith(customExercisePrefix)) return true;
  if ((exercise.catalogSource ?? '').trim().toLowerCase() == 'custom') {
    return true;
  }
  return id.isEmpty;
}

const legacyEnglishCategories = <String, (String, String)>{
  'chest': ('Brust', 'brust'),
  'back': ('Rücken', 'latissimus'),
  'shoulders': ('Schultern', 'schulter_vorne'),
  'shoulder': ('Schultern', 'schulter_vorne'),
  'arms': ('Bizeps', 'bizeps'),
  'arm': ('Bizeps', 'bizeps'),
  'biceps': ('Bizeps', 'bizeps'),
  'triceps': ('Trizeps', 'trizeps'),
  'legs': ('Beine', 'quadrizeps'),
  'leg': ('Beine', 'quadrizeps'),
  'calves': ('Beine', 'waden'),
  'calf': ('Beine', 'waden'),
  'core': ('Bauch', 'bauch_gerade'),
  'abs': ('Bauch', 'bauch_gerade'),
};

const categoryPrimaryMuscle = <String, String>{
  'Brust': 'brust',
  'Rücken': 'latissimus',
  'Schultern': 'schulter_vorne',
  'Beine': 'quadrizeps',
  'Bizeps': 'bizeps',
  'Trizeps': 'trizeps',
  'Bauch': 'bauch_gerade',
};

class LegacyCustomFields {
  const LegacyCustomFields({
    required this.category,
    required this.equipment,
    required this.primaryMuscles,
    required this.grip,
    required this.position,
    required this.changed,
  });

  final String category;
  final String equipment;
  final List<String> primaryMuscles;
  final String grip;
  final String position;
  final bool changed;
}

List<String> decodeMuscleList(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return [
        for (final item in decoded)
          if (item is String && exerciseMuscleKeys.contains(item)) item,
      ];
    }
  } catch (_) {}
  return const [];
}

const legacyCustomRepairVersion = 1;

const _inventedCategory = 'Brust';
const _inventedGear = 'Körpergewicht';
const _inventedMuscle = 'brust';

bool inventedCategoryFallback(Exercise exercise) {
  if ((exercise.catalogId ?? '').startsWith(customExercisePrefix)) return false;
  if ((exercise.bewegung ?? '').trim().isNotEmpty) return false;
  if ((exercise.familie ?? '').trim().isNotEmpty) return false;
  if (decodeMuscleList(exercise.secondaryMuscles).isNotEmpty) return false;
  if ((exercise.griff ?? '').trim().isNotEmpty) return false;
  if ((exercise.position ?? '').trim().isNotEmpty) return false;
  if ((exercise.catalogSource ?? '').trim().toLowerCase() != 'custom') {
    return false;
  }
  final category = (exercise.categoryName ?? '').trim();
  final muscle = (exercise.muscle ?? '').trim();
  if (category != _inventedCategory) return false;
  if (muscle.isNotEmpty && muscle != _inventedCategory) return false;
  if ((exercise.equipment ?? '').trim() != _inventedGear) return false;
  final primary = decodeMuscleList(exercise.primaryMuscles);
  if (primary.isEmpty) return true;
  return primary.length == 1 && primary.single == _inventedMuscle;
}

LegacyCustomFields normalizeLegacyCustomExercise(Exercise exercise) {
  final storedCategory = (exercise.categoryName ?? exercise.muscle ?? '')
      .trim();
  final english = legacyEnglishCategories[storedCategory.toLowerCase()];
  final category = exerciseCategories.contains(storedCategory)
      ? storedCategory
      : (english?.$1 ?? '');
  final storedMuscles = decodeMuscleList(exercise.primaryMuscles);
  var muscles = storedMuscles;
  if (muscles.isEmpty) {
    final fill = english?.$2 ?? categoryPrimaryMuscle[category];
    if (fill != null) muscles = [fill];
  }
  final storedGear = (exercise.equipment ?? '').trim();
  final mappedGear = exerciseGearValues.contains(storedGear)
      ? storedGear
      : hevyEquipmentGear(storedGear);
  final gear = mappedGear ?? storedGear;
  final storedGrip = (exercise.griff ?? '').trim();
  final grip = exerciseGripValues.contains(storedGrip) ? storedGrip : '';
  final storedPosition = (exercise.position ?? '').trim();
  final position = exercisePositionValues.contains(storedPosition)
      ? storedPosition
      : '';
  final changed =
      category != storedCategory ||
      gear != storedGear ||
      muscles.join('|') != storedMuscles.join('|') ||
      grip != storedGrip ||
      position != storedPosition;
  return LegacyCustomFields(
    category: category,
    equipment: gear,
    primaryMuscles: muscles,
    grip: grip,
    position: position,
    changed: changed,
  );
}

final bundledExerciseNames = {for (final entry in defaultExercises) entry.$1};

Future<bool> legacyCustomRepairDone(AppDatabase database) async {
  final setting = await (database.select(
    database.settings,
  )..limit(1)).getSingleOrNull();
  return setting != null &&
      setting.legacyRepairVersion >= legacyCustomRepairVersion;
}

Future<int> repairLegacyCustomExercises(
  AppDatabase database, {
  String? flexifyMapRaw,
}) async {
  if (await legacyCustomRepairDone(database)) return 0;
  final rows = await database.select(database.exercises).get();
  final index = _CatalogNameIndex()..addAll(rows, flexifyMapRaw);
  var updated = 0;
  for (final exercise in rows) {
    if (!isCustomExercise(exercise)) continue;
    final owned =
        (exercise.catalogId ?? '').startsWith(customExercisePrefix) ||
        (exercise.catalogSource ?? '').trim().toLowerCase() == 'custom';
    final storedCategory = (exercise.categoryName ?? exercise.muscle ?? '')
        .trim();
    final english =
        legacyEnglishCategories[storedCategory.toLowerCase()] != null;
    final invented = inventedCategoryFallback(exercise);
    final source = invented ? _withoutInventedFallback(exercise) : exercise;
    final match = index.lookup(source);
    final bundled = bundledExerciseNames.contains(exercise.name);
    if (!owned && !english && match == null && bundled && !invented) continue;
    final wrote = match == null
        ? await _writeNormalized(database, exercise, source)
        : await _writeCatalogMatch(database, source, match);
    if (wrote) updated++;
  }
  await database
      .update(database.settings)
      .write(
        const SettingsCompanion(
          legacyRepairVersion: Value(legacyCustomRepairVersion),
        ),
      );
  return updated;
}

Exercise _withoutInventedFallback(Exercise exercise) {
  return exercise.copyWith(
    categoryName: const Value(null),
    muscle: const Value(null),
    equipment: const Value(null),
    primaryMuscles: const Value(null),
    catalogSource: const Value(null),
  );
}

class _CatalogNameIndex {
  final _byKey = <String, Exercise>{};

  void addAll(List<Exercise> rows, String? flexifyMapRaw) {
    final byCatalogId = <String, Exercise>{};
    for (final row in rows) {
      if (!isCatalogExercise(
        catalogId: row.catalogId,
        catalogSource: row.catalogSource,
      )) {
        continue;
      }
      final catalogId = row.catalogId!.trim();
      byCatalogId[catalogId] = row;
      _add(row.name, row);
      final german = (row.germanName ?? '').trim();
      if (german.isNotEmpty) _add(german, row);
      for (final alias in decodeCatalogList(row.aliases)) {
        _add(alias, row);
      }
      final english = (row.englishName ?? '').trim();
      if (english.isNotEmpty) _add(english, row);
      for (final alias in decodeCatalogList(row.englishAliases)) {
        _add(alias, row);
      }
    }
    for (final entry in _flexifySeedNames(flexifyMapRaw).entries) {
      final exercise = byCatalogId[entry.key];
      if (exercise == null) continue;
      for (final name in entry.value) {
        _add(name, exercise);
      }
    }
  }

  Exercise? lookup(Exercise exercise) {
    final queries = [
      exercise.name,
      if ((exercise.germanName ?? '').trim().isNotEmpty) exercise.germanName!,
    ];
    Exercise? best;
    for (final query in queries) {
      final hit = _byKey[foldExerciseSearch(query)];
      if (hit == null || hit.id == exercise.id) continue;
      if (best == null || _prefers(query, hit, best)) best = hit;
    }
    return best;
  }

  void _add(String label, Exercise exercise) {
    final key = foldExerciseSearch(label);
    if (key.isEmpty) return;
    final current = _byKey[key];
    if (current == null || _prefers(label, exercise, current)) {
      _byKey[key] = exercise;
    }
  }

  bool _prefers(String query, Exercise left, Exercise right) {
    return compareExerciseSearch(
          query: query,
          leftName: left.name,
          leftGermanName: left.germanName,
          leftAliases: left.aliases,
          leftEnglishName: left.englishName,
          leftEnglishAliases: left.englishAliases,
          rightName: right.name,
          rightGermanName: right.germanName,
          rightAliases: right.aliases,
          rightEnglishName: right.englishName,
          rightEnglishAliases: right.englishAliases,
        ) <
        0;
  }
}

Map<String, List<String>> _flexifySeedNames(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const {};
  Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } catch (_) {
    return const {};
  }
  if (decoded is! Map) return const {};
  final names = <String, List<String>>{};
  for (final entry in decoded.entries) {
    final id = entry.key;
    if (id is! String || id.trim().isEmpty) continue;
    final value = entry.value;
    if (value is! Map) continue;
    final list = value['seed_namen'];
    if (list is! List) continue;
    final seeds = [
      for (final item in list)
        if (item is String && item.trim().isNotEmpty) item.trim(),
    ];
    if (seeds.isNotEmpty) names[id] = seeds;
  }
  return names;
}

Future<bool> _writeNormalized(
  AppDatabase database,
  Exercise original,
  Exercise source,
) async {
  final fields = normalizeLegacyCustomExercise(source);
  final category = fields.category.isEmpty ? null : fields.category;
  final gear = _knownGear(fields.equipment);
  final muscles = fields.primaryMuscles;
  final sameCategory = (original.categoryName ?? '').trim() == (category ?? '');
  final sameMuscle = (original.muscle ?? '').trim() == (category ?? '');
  final sameGear = (original.equipment ?? '').trim() == (gear ?? '');
  final samePrimary =
      decodeMuscleList(original.primaryMuscles).join('|') == muscles.join('|');
  if (sameCategory && sameMuscle && sameGear && samePrimary) return false;
  await (database.update(
    database.exercises,
  )..where((row) => row.id.equals(original.id))).write(
    ExercisesCompanion(
      categoryName: Value(category),
      muscle: Value(category),
      equipment: Value(gear),
      primaryMuscles: Value(muscles.isEmpty ? null : _jsonList(muscles)),
      griff: Value(fields.grip.isEmpty ? null : fields.grip),
      position: Value(fields.position.isEmpty ? null : fields.position),
      catalogSource: Value(
        category == null && gear == null && muscles.isEmpty
            ? null
            : _customSource(original),
      ),
    ),
  );
  return true;
}

Future<bool> _writeCatalogMatch(
  AppDatabase database,
  Exercise exercise,
  Exercise match,
) async {
  final storedCategory = (exercise.categoryName ?? exercise.muscle ?? '')
      .trim();
  final category =
      _knownCategory(storedCategory) ??
      _knownCategory(match.categoryName) ??
      _knownCategory(match.muscle);
  final gear = _knownGear(exercise.equipment) ?? _knownGear(match.equipment);
  final storedPrimary = decodeMuscleList(exercise.primaryMuscles);
  final matchedPrimary = decodeMuscleList(match.primaryMuscles);
  final muscles = storedPrimary.isNotEmpty ? storedPrimary : matchedPrimary;
  final secondary = decodeMuscleList(match.secondaryMuscles);
  final movement = (match.bewegung ?? '').trim();
  final sameCategory =
      (exercise.categoryName ?? '').trim() == (category ?? '') &&
      (exercise.muscle ?? '').trim() == (category ?? '');
  final sameGear = (exercise.equipment ?? '').trim() == (gear ?? '');
  final samePrimary =
      decodeMuscleList(exercise.primaryMuscles).join('|') == muscles.join('|');
  if (sameCategory && sameGear && samePrimary && _hasCustomSource(exercise)) {
    return false;
  }
  await (database.update(
    database.exercises,
  )..where((row) => row.id.equals(exercise.id))).write(
    ExercisesCompanion(
      categoryName: Value(category),
      muscle: Value(category),
      equipment: Value(gear),
      primaryMuscles: Value(_jsonList(muscles)),
      secondaryMuscles: Value(_jsonList(secondary)),
      bewegung: Value(
        (exercise.bewegung ?? '').trim().isEmpty
            ? (movement.isEmpty ? null : movement)
            : exercise.bewegung,
      ),
      familie: Value(
        (exercise.familie ?? '').trim().isEmpty
            ? match.familie
            : exercise.familie,
      ),
      griff: Value(
        (exercise.griff ?? '').trim().isEmpty ? match.griff : exercise.griff,
      ),
      position: Value(
        (exercise.position ?? '').trim().isEmpty
            ? match.position
            : exercise.position,
      ),
      einseitig: Value(exercise.einseitig || match.einseitig),
      catalogSource: Value(_customSource(exercise)),
    ),
  );
  return true;
}

bool _hasCustomSource(Exercise exercise) =>
    (exercise.catalogSource ?? '').trim().toLowerCase() == 'custom';

String _customSource(Exercise exercise) {
  final source = (exercise.catalogSource ?? '').trim();
  return source.isEmpty ? 'custom' : source;
}

String? _knownCategory(String? value) {
  final text = (value ?? '').trim();
  if (exerciseCategories.contains(text)) return text;
  return legacyEnglishCategories[text.toLowerCase()]?.$1;
}

String? _knownGear(String? value) {
  final text = (value ?? '').trim();
  if (exerciseGearValues.contains(text)) return text;
  return hevyEquipmentGear(text);
}

String customExerciseSlug(String name) {
  var value = name.trim().toLowerCase();
  const replacements = {'ä': 'ae', 'ö': 'oe', 'ü': 'ue', 'ß': 'ss'};
  for (final entry in replacements.entries) {
    value = value.replaceAll(entry.key, entry.value);
  }
  value = value
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'-{2,}'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  if (value.isEmpty) return 'uebung';
  return value;
}

Future<String> uniqueCustomCatalogId(
  AppDatabase database,
  String name, {
  int? keepId,
}) async {
  final base = '$customExercisePrefix${customExerciseSlug(name)}';
  var candidate = base;
  var suffix = 2;
  while (true) {
    final existing = await (database.select(
      database.exercises,
    )..where((row) => row.catalogId.equals(candidate))).getSingleOrNull();
    if (existing == null || existing.id == keepId) return candidate;
    candidate = '$base-$suffix';
    suffix++;
  }
}

class CustomExerciseDraft {
  const CustomExerciseDraft({
    required this.name,
    required this.category,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.equipment,
    required this.movement,
    this.family = '',
    this.grip = '',
    this.position = '',
    this.unilateral = false,
  });

  final String name;
  final String category;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final String equipment;
  final String movement;
  final String family;
  final String grip;
  final String position;
  final bool unilateral;
}

String? validateCustomExercise(CustomExerciseDraft draft) {
  if (draft.name.trim().isEmpty) return 'name';
  if (!exerciseCategories.contains(draft.category)) return 'category';
  if (draft.primaryMuscles.isEmpty ||
      draft.primaryMuscles.any((key) => !exerciseMuscleKeys.contains(key))) {
    return 'muscles';
  }
  if (draft.secondaryMuscles.any((key) => !exerciseMuscleKeys.contains(key))) {
    return 'muscles';
  }
  if (!exerciseGearValues.contains(draft.equipment)) return 'gear';
  if (!exerciseMotionValues.contains(draft.movement)) return 'movement';
  final family = draft.family.trim();
  if (family.isNotEmpty &&
      !RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(family)) {
    return 'family';
  }
  if (draft.grip.isNotEmpty && !exerciseGripValues.contains(draft.grip)) {
    return 'grip';
  }
  if (draft.position.isNotEmpty &&
      !exercisePositionValues.contains(draft.position)) {
    return 'position';
  }
  return null;
}

Future<Exercise> saveCustomExercise(
  AppDatabase database,
  CustomExerciseDraft draft, {
  Exercise? existing,
}) async {
  final name = draft.name.trim();
  final catalogId =
      existing?.catalogId?.startsWith(customExercisePrefix) == true
      ? existing!.catalogId!
      : await uniqueCustomCatalogId(database, name);
  final categoryId = await _categoryId(database, draft.category);
  final cardio = draft.category == 'Cardio';
  final storedName = await _storedName(
    database,
    name: name,
    fallback: catalogId,
    keepId: existing?.id,
  );
  final companion = ExercisesCompanion(
    name: Value(storedName),
    kind: Value(cardio ? 'cardio' : 'strength'),
    displayUnit: Value(cardio ? 'km' : 'kg'),
    categoryId: Value(categoryId),
    germanName: Value(name),
    muscle: Value(draft.category),
    catalogId: Value(catalogId),
    categoryName: Value(draft.category),
    equipment: Value(draft.equipment),
    primaryMuscles: Value(_jsonList(draft.primaryMuscles)),
    secondaryMuscles: Value(_jsonList(draft.secondaryMuscles)),
    familie: Value(draft.family.trim().isEmpty ? null : draft.family.trim()),
    bewegung: Value(draft.movement),
    griff: Value(draft.grip.isEmpty ? null : draft.grip),
    position: Value(draft.position.isEmpty ? null : draft.position),
    einseitig: Value(draft.unilateral),
    catalogSource: const Value('custom'),
    archived: const Value(false),
  );
  final id = existing == null
      ? await database.into(database.exercises).insert(companion)
      : existing.id;
  if (existing != null) {
    await (database.update(
      database.exercises,
    )..where((row) => row.id.equals(existing.id))).write(companion);
  }
  return (database.select(
    database.exercises,
  )..where((row) => row.id.equals(id))).getSingle();
}

Future<void> deleteCustomExercise(
  AppDatabase database,
  Exercise exercise,
) async {
  await (database.delete(
    database.planExercises,
  )..where((row) => row.exerciseId.equals(exercise.id))).go();
  await (database.update(database.exercises)
        ..where((row) => row.id.equals(exercise.id)))
      .write(const ExercisesCompanion(archived: Value(true)));
}

String _jsonList(List<String> values) {
  final encoded = values.map((value) => '"$value"').join(',');
  return '[$encoded]';
}

Future<int?> _categoryId(AppDatabase database, String name) async {
  final existing = await (database.select(
    database.categories,
  )..where((row) => row.name.equals(name))).getSingleOrNull();
  if (existing != null) return existing.id;
  return database
      .into(database.categories)
      .insert(CategoriesCompanion.insert(name: name));
}

Future<String> _storedName(
  AppDatabase database, {
  required String name,
  required String fallback,
  int? keepId,
}) async {
  for (final candidate in [name, fallback]) {
    final existing = await (database.select(
      database.exercises,
    )..where((row) => row.name.equals(candidate))).getSingleOrNull();
    if (existing == null || existing.id == keepId) return candidate;
  }
  return fallback;
}
