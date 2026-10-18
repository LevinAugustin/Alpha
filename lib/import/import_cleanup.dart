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

bool markedImport(String? batch) => (batch ?? '').trim().isNotEmpty;

bool legacyBrokenImport({
  required String? importBatch,
  required DateTime started,
  required DateTime? ended,
  required int setCount,
  required int unmarkedSameSecond,
}) {
  if (markedImport(importBatch)) return false;
  if (!importedStub(started, ended)) return false;
  return setCount == 1 || unmarkedSameSecond > 1;
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
  final sets = await database.select(database.exerciseSets).get();
  final setCounts = <int, int>{};
  for (final set in sets) {
    final workoutId = set.workoutId;
    if (workoutId == null) continue;
    setCounts[workoutId] = (setCounts[workoutId] ?? 0) + 1;
  }
  final unmarkedSameSecond = <DateTime, int>{};
  for (final row in workouts) {
    if (markedImport(row.importBatch)) continue;
    if (!importedStub(row.startedAt, row.endedAt)) continue;
    final second = importSecond(row.startedAt);
    unmarkedSameSecond[second] = (unmarkedSameSecond[second] ?? 0) + 1;
  }
  final stubs = [
    for (final row in workouts)
      if (legacyBrokenImport(
        importBatch: row.importBatch,
        started: row.startedAt,
        ended: row.endedAt,
        setCount: setCounts[row.id] ?? 0,
        unmarkedSameSecond:
            unmarkedSameSecond[importSecond(row.startedAt)] ?? 0,
      ))
        row,
  ];
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
