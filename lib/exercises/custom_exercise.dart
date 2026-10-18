import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flexify/database/database.dart';
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

LegacyCustomFields normalizeLegacyCustomExercise(Exercise exercise) {
  final storedCategory = (exercise.categoryName ?? exercise.muscle ?? '')
      .trim();
  final english = legacyEnglishCategories[storedCategory.toLowerCase()];
  var category = storedCategory;
  if (!exerciseCategories.contains(category)) {
    category = english?.$1 ?? exerciseCategories.first;
  }
  final storedMuscles = decodeMuscleList(exercise.primaryMuscles);
  var muscles = storedMuscles;
  if (muscles.isEmpty) {
    final fromEnglish = english?.$2;
    final fromCategory = categoryPrimaryMuscle[category];
    final fill = fromEnglish ?? fromCategory;
    if (fill != null) muscles = [fill];
  }
  final storedGear = (exercise.equipment ?? '').trim();
  var gear = storedGear;
  if (!exerciseGearValues.contains(gear)) {
    gear = storedGear.isEmpty
        ? 'Körpergewicht'
        : (hevyEquipmentGear(storedGear) ?? 'Körpergewicht');
  }
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

Future<int> repairLegacyCustomExercises(AppDatabase database) async {
  final rows = await database.select(database.exercises).get();
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
    if (!owned && !english) continue;
    final fields = normalizeLegacyCustomExercise(exercise);
    if (!fields.changed) continue;
    await (database.update(
      database.exercises,
    )..where((row) => row.id.equals(exercise.id))).write(
      ExercisesCompanion(
        categoryName: Value(fields.category),
        muscle: Value(fields.category),
        equipment: Value(fields.equipment),
        primaryMuscles: Value(_jsonList(fields.primaryMuscles)),
        griff: Value(fields.grip.isEmpty ? null : fields.grip),
        position: Value(fields.position.isEmpty ? null : fields.position),
      ),
    );
    updated++;
  }
  return updated;
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
