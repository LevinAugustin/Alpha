import 'package:flexify/database/database.dart';

class ImportCleanupGroup {
  const ImportCleanupGroup({required this.second, required this.workouts});

  final DateTime second;
  final int workouts;
}

class ImportCleanupPreview {
  const ImportCleanupPreview({
    required this.groups,
    required this.workoutIds,
    required this.planIds,
  });

  final List<ImportCleanupGroup> groups;
  final List<int> workoutIds;
  final List<int> planIds;

  bool get isEmpty => workoutIds.isEmpty && planIds.isEmpty;
}

bool importedStub(DateTime started, DateTime? ended) {
  if (ended == null) return false;
  return started.year == ended.year &&
      started.month == ended.month &&
      started.day == ended.day &&
      started.hour == ended.hour &&
      started.minute == ended.minute &&
      started.second == ended.second;
}

DateTime importSecond(DateTime value) => DateTime(
  value.year,
  value.month,
  value.day,
  value.hour,
  value.minute,
  value.second,
);

Future<ImportCleanupPreview> previewImportCleanup(AppDatabase database) async {
  final workouts = await database.select(database.workouts).get();
  final stubs = workouts
      .where((row) => importedStub(row.startedAt, row.endedAt))
      .toList();
  final stubIds = stubs.map((row) => row.id).toSet();
  final byPlan = <int, List<Workout>>{};
  for (final workout in workouts) {
    final planId = workout.planId;
    if (planId == null) continue;
    byPlan.putIfAbsent(planId, () => []).add(workout);
  }
  final planIds = <int>[];
  for (final entry in byPlan.entries) {
    final linked = entry.value;
    if (linked.isEmpty) continue;
    if (linked.every((row) => stubIds.contains(row.id))) {
      planIds.add(entry.key);
    }
  }
  final counts = <DateTime, int>{};
  for (final stub in stubs) {
    final second = importSecond(stub.startedAt);
    counts[second] = (counts[second] ?? 0) + 1;
  }
  final groups = [
    for (final entry in counts.entries)
      ImportCleanupGroup(second: entry.key, workouts: entry.value),
  ]..sort((a, b) => a.second.compareTo(b.second));
  return ImportCleanupPreview(
    groups: groups,
    workoutIds: stubs.map((row) => row.id).toList(),
    planIds: planIds,
  );
}

Future<void> applyImportCleanup(
  AppDatabase database,
  ImportCleanupPreview preview,
) async {
  if (preview.isEmpty) return;
  await database.transaction(() async {
    if (preview.workoutIds.isNotEmpty) {
      await (database.delete(
        database.exerciseSets,
      )..where((row) => row.workoutId.isIn(preview.workoutIds))).go();
      await (database.delete(
        database.workouts,
      )..where((row) => row.id.isIn(preview.workoutIds))).go();
    }
    if (preview.planIds.isNotEmpty) {
      await (database.delete(
        database.planExercises,
      )..where((row) => row.planId.isIn(preview.planIds))).go();
      await (database.delete(
        database.plans,
      )..where((row) => row.id.isIn(preview.planIds))).go();
    }
  });
}
