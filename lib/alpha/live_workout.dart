import 'package:drift/drift.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/plan/plan_names.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';

class LiveWorkout {
  LiveWorkout({
    required this.planId,
    required this.workoutId,
    required this.title,
    required this.exercise,
  });

  final int planId;
  final int workoutId;
  String title;
  String exercise;
}

final ValueNotifier<LiveWorkout?> liveWorkout = ValueNotifier(null);

Future<void> restoreLiveWorkout(AppDatabase database) async {
  final open =
      await (database.select(database.workouts)
            ..where((row) => row.endedAt.isNull())
            ..orderBy([
              (row) => OrderingTerm.desc(row.startedAt),
              (row) => OrderingTerm.desc(row.id),
            ])
            ..limit(1))
          .getSingleOrNull();
  final planId = open?.planId;
  if (open == null || planId == null) {
    liveWorkout.value = null;
    return;
  }
  final plan = await (database.select(
    database.plans,
  )..where((row) => row.id.equals(planId))).getSingleOrNull();
  if (plan == null) {
    liveWorkout.value = null;
    return;
  }
  final setting = await (database.select(
    database.settings,
  )..limit(1)).getSingleOrNull();
  final locale = (setting?.localeOverride ?? '').trim();
  final language = locale.isEmpty ? 'de' : locale;
  await initializeDateFormatting(language);
  final title = localizedPlanTitle(
    locale: language,
    title: plan.title,
    sequence: plan.sequence,
    id: plan.id,
  );
  liveWorkout.value = LiveWorkout(
    planId: plan.id,
    workoutId: open.id,
    title: title,
    exercise: await _liveExerciseName(database, open.id, plan.id, title),
  );
}

Future<String> _liveExerciseName(
  AppDatabase database,
  int workoutId,
  int planId,
  String fallback,
) async {
  final latest =
      await (database.select(database.exerciseSets)
            ..where((row) => row.workoutId.equals(workoutId))
            ..orderBy([(row) => OrderingTerm.desc(row.id)])
            ..limit(1))
          .getSingleOrNull();
  final fromSet = latest?.exerciseId;
  final fromPlan = fromSet == null
      ? (await (database.select(database.planExercises)
                  ..where(
                    (row) =>
                        row.planId.equals(planId) & row.enabled.equals(true),
                  )
                  ..orderBy([(row) => OrderingTerm.asc(row.sequence)])
                  ..limit(1))
                .getSingleOrNull())
            ?.exerciseId
      : null;
  final exerciseId = fromSet ?? fromPlan;
  if (exerciseId == null) return fallback;
  final exercise = await (database.select(
    database.exercises,
  )..where((row) => row.id.equals(exerciseId))).getSingleOrNull();
  if (exercise == null) return fallback;
  final german = (exercise.germanName ?? '').trim();
  return german.isEmpty ? exercise.name : german;
}
