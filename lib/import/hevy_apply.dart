import 'package:drift/drift.dart';
import 'package:flexify/database/body_weight_repository.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/database/exercise_set_repository.dart';
import 'package:flexify/import/hevy_import.dart';

Future<void> applyWorkoutImport({
  required AppDatabase database,
  required List<ImportedSet> sets,
  required List<ImportedTemplate> templates,
  required Exercise? Function(String name) match,
  required int existingPlanCount,
  required Set<String> existingTitles,
}) async {
  final byOriginal = {
    for (final template in templates) template.originalTitle: template,
  };
  final usable = sets
      .where((set) => byOriginal.containsKey(set.workoutTitle))
      .toList();
  final bodyWeight = await getLatestBodyWeight(database);
  final matched = <String, Exercise?>{};
  Exercise? cachedMatch(String name) {
    return matched.putIfAbsent(name, () => match(name));
  }

  final importBatch = '2.5.1-${DateTime.now().microsecondsSinceEpoch}';
  await database.transaction(() async {
    final byWorkout = <String, int>{};
    final planIds = <String, int?>{};
    var createdPlans = existingPlanCount;
    for (final set in usable) {
      final template = byOriginal[set.workoutTitle]!;
      final key = '${set.workoutTitle}|${set.started.toIso8601String()}';
      var workoutId = byWorkout[key];
      if (workoutId == null) {
        if (!planIds.containsKey(template.originalTitle)) {
          planIds[template.originalTitle] = await _planFor(
            database,
            template,
            createdPlans,
            cachedMatch,
          );
          if (planIds[template.originalTitle] != null &&
              !existingTitles.contains(template.title.trim())) {
            createdPlans += 1;
            existingTitles.add(template.title.trim());
          }
        }
        workoutId = await database.workouts.insertOne(
          WorkoutsCompanion.insert(
            planId: Value(planIds[template.originalTitle]),
            startedAt: set.started,
            endedAt: Value(set.ended ?? set.started),
            importBatch: Value(importBatch),
          ),
        );
        byWorkout[key] = workoutId;
      }
      final exercise = cachedMatch(set.exercise);
      if (exercise == null) continue;
      await insertExerciseSet(
        database,
        exerciseId: exercise.id,
        workoutId: workoutId,
        bodyWeightKg: bodyWeight?.weightKg,
        lookupBodyWeight: false,
        readBack: false,
        exerciseSet: ExerciseSetView(
          id: 0,
          bodyWeight: 0,
          cardio: exercise.kind == 'cardio',
          created: set.started,
          distance: 0,
          duration: 0,
          name: exercise.name,
          notes: set.warmup ? '[warmup]' : '',
          planId: planIds[template.originalTitle],
          reps: set.reps,
          unit: 'kg',
          weight: set.kg,
        ),
      );
    }
  });
}

Future<int?> _planFor(
  AppDatabase database,
  ImportedTemplate template,
  int createdPlans,
  Exercise? Function(String name) match,
) async {
  final existing = await (database.select(
    database.plans,
  )..where((row) => row.title.equals(template.title))).getSingleOrNull();
  if (existing != null) return existing.id;
  if (createdPlans >= hevyTemplateLimit) return null;
  final id = await database.plans.insertOne(
    PlansCompanion.insert(
      days: '',
      title: Value(template.title),
      sequence: Value(createdPlans),
    ),
  );
  var sequence = 0;
  for (final name in template.exercises) {
    final exercise = match(name);
    if (exercise == null) continue;
    await database
        .into(database.planExercises)
        .insert(
          PlanExercisesCompanion.insert(
            enabled: true,
            exerciseId: exercise.id,
            planId: id,
            maxSets: Value(template.setCounts[name]),
            sequence: Value(sequence++),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }
  return id;
}
