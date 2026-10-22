import 'package:drift/drift.dart' hide isNull;
import 'package:flexify/alpha/alpha_prefs.dart';
import 'package:flexify/alpha/gym_start_sheet.dart';
import 'package:flexify/alpha/set_notes.dart';
import 'package:flexify/alpha/unilateral_sets.dart';
import 'package:flexify/constants.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/database/exercise_analytics.dart';
import 'package:flexify/database/exercise_set_repository.dart';
import 'package:flexify/exercises/exercise_detail_page.dart';
import 'package:flexify/l10n/generated/app_localizations_en.dart';
import 'package:flexify/workout/gym_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_app.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('equal sides share one reps number and volume counts both', () {
    expect(pairedRepsLabel(8, 8, (value) => '${value?.round()}'), '8');
    expect(pairedRepsLabel(12, 10, (value) => '${value?.round()}'), '12/10');
    expect(pairedRepsLabel(8, null, (value) => '${value?.round()}'), '8');
    expect(
      unilateralVolume(unilateral: true, side: null, loadKg: 16, reps: 8),
      256,
    );
    expect(
      unilateralVolume(unilateral: true, side: 'links', loadKg: 16, reps: 8),
      128,
    );
    expect(
      unilateralVolume(unilateral: false, side: null, loadKg: 16, reps: 8),
      128,
    );
    final now = DateTime(2026, 10, 22, 9);
    expect(lastTrainedWhen(l10n, now, now), 'today');
    expect(
      lastTrainedWhen(l10n, now.subtract(const Duration(days: 1)), now),
      'yesterday',
    );
    expect(
      lastTrainedWhen(l10n, now.subtract(const Duration(days: 3)), now),
      '3 days ago',
    );
    final stamp = DateTime(2026, 10, 22, 8);
    final kept = indexesAfterEqualSideCollapse([
      SideExportRow(
        exerciseId: 1,
        loggedAt: stamp,
        side: 'links',
        kg: 16,
        reps: 8,
      ),
      SideExportRow(
        exerciseId: 1,
        loggedAt: stamp,
        side: 'rechts',
        kg: 16,
        reps: 8,
      ),
      SideExportRow(
        exerciseId: 1,
        loggedAt: stamp.add(const Duration(minutes: 1)),
        side: 'links',
        kg: 16,
        reps: 12,
      ),
      SideExportRow(
        exerciseId: 1,
        loggedAt: stamp.add(const Duration(minutes: 1)),
        side: 'rechts',
        kg: 16,
        reps: 10,
      ),
    ]);
    expect(kept, [0, 2, 3]);
    expect(
      hasCreatedStudios([GymPlace(id: 'default', name: 'Studio')]),
      isFalse,
    );
    expect(
      hasCreatedStudios([
        GymPlace(id: 'default', name: 'Studio'),
        GymPlace(id: 'h', name: 'Hannover'),
      ]),
      isTrue,
    );
  });

  testWidgets('unilateral sets default to kg and reps', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    await _quietTimers(harness.database);
    await _resetGyms();
    final exercise = await _unilateral(harness.database, 'Cable hammer curl');
    final plan = await _planWith(harness.database, [exercise]);

    await harness.pump(
      tester,
      GymWorkoutPage(plan: plan),
      surfaceSize: const Size(400, 900),
    );
    await tester.pumpAndSettle();

    expect(find.text('KG'), findsWidgets);
    expect(find.text('REPS'), findsWidgets);
    expect(find.text('Left'), findsNothing);
    expect(find.byKey(Key('set-reps-right-${exercise.id}-0')), findsNothing);

    await tester.enterText(find.byKey(Key('set-kg-${exercise.id}-0')), '16');
    await tester.enterText(find.byKey(Key('set-reps-${exercise.id}-0')), '8');
    await tester.tap(find.byKey(Key('set-check-${exercise.id}-0')));
    await tester.pumpAndSettle();

    final saved = await harness.database.exerciseSets.select().get();
    expect(saved, hasLength(1));
    expect(saved.single.side, isNull);
    expect(saved.single.reps, 8);
    expect(saved.single.loadKg, 16);

    await tester.tap(find.byKey(Key('split-sides-${exercise.id}')));
    await tester.pumpAndSettle();
    expect(find.text('Left'), findsOneWidget);
    expect(find.text('Right'), findsOneWidget);
    expect(find.byKey(Key('set-reps-right-${exercise.id}-1')), findsOneWidget);
    await tester.enterText(find.byKey(Key('set-kg-${exercise.id}-1')), '18');
    await tester.enterText(find.byKey(Key('set-reps-${exercise.id}-1')), '12');
    await tester.enterText(
      find.byKey(Key('set-reps-right-${exercise.id}-1')),
      '10',
    );
    await tester.tap(find.byKey(Key('set-check-${exercise.id}-1')));
    await tester.pumpAndSettle();
    final split = await harness.database.exerciseSets.select().get();
    expect(
      split.map((set) => (set.side, set.reps)).toSet(),
      containsAll([(null, 8.0), ('links', 12.0), ('rechts', 10.0)]),
    );
  });

  testWidgets('old left and right values stay visible', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    await _quietTimers(harness.database);
    await _resetGyms();
    final exercise = await _unilateral(harness.database, 'One arm row');
    final plan = await _planWith(harness.database, [exercise]);
    final past = await harness.database.workouts.insertOne(
      WorkoutsCompanion.insert(
        planId: Value(plan.id),
        startedAt: DateTime(2026, 10, 1, 8),
        endedAt: Value(DateTime(2026, 10, 1, 9)),
      ),
    );
    final equalAt = DateTime(2026, 10, 1, 8, 5);
    final unevenAt = DateTime(2026, 10, 1, 8, 10);
    await _side(harness.database, exercise, past, equalAt, 'links', 8);
    await _side(harness.database, exercise, past, equalAt, 'rechts', 8);
    await _side(harness.database, exercise, past, unevenAt, 'links', 12);
    await _side(harness.database, exercise, past, unevenAt, 'rechts', 10);

    await harness.pump(
      tester,
      GymWorkoutPage(plan: plan),
      surfaceSize: const Size(400, 900),
    );
    await tester.pumpAndSettle();
    expect(find.text('20 kg × 8'), findsOneWidget);
    expect(find.text('20 kg × 12/10'), findsOneWidget);
    expect(find.text('20 kg × 8/8'), findsNothing);

    await harness.pump(
      tester,
      ExerciseDetailPage(exercise: exercise),
      surfaceSize: const Size(400, 900),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('20 kg × 8'), findsOneWidget);
    expect(find.text('20 kg × 12/10'), findsOneWidget);
    expect(find.textContaining('Left'), findsNothing);
  });

  test('a reps-only set is ranked against old sides and counts both', () async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    final exercise = await _unilateral(harness.database, 'Rope curl');
    final workout = await harness.database.workouts.insertOne(
      WorkoutsCompanion.insert(startedAt: DateTime(2026, 10, 2, 8)),
    );
    final at = DateTime(2026, 10, 2, 8, 1);
    await _side(harness.database, exercise, workout, at, 'links', 8, kg: 10);
    await _side(harness.database, exercise, workout, at, 'rechts', 8, kg: 10);
    final tied = await insertExerciseSet(
      harness.database,
      exerciseId: exercise.id,
      workoutId: workout,
      exerciseSet: _view(exercise.name, 8, 10, DateTime(2026, 10, 3, 8)),
    );
    expect(await isBestExerciseSet(harness.database, tied), isFalse);
    final better = await insertExerciseSet(
      harness.database,
      exerciseId: exercise.id,
      workoutId: workout,
      exerciseSet: _view(exercise.name, 9, 10, DateTime(2026, 10, 4, 8)),
    );
    expect(await isBestExerciseSet(harness.database, better), isTrue);
    final volume = await getStrengthData(
      target: 'kg',
      name: exercise.name,
      metric: StrengthMetric.volume,
      period: Period.month,
      start: DateTime(2026, 10, 1),
      end: DateTime(2026, 11, 1),
      limit: 4,
    );
    final total = volume.fold<double>(0, (sum, row) => sum + row.value);
    expect(total, 500);
  });

  testWidgets('studio sheet assigns the gym and cancel starts nothing', (
    tester,
  ) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    addTearDown(_resetGyms);
    await _quietTimers(harness.database);
    final exercise = await _unilateral(harness.database, 'Bench');
    await (harness.database.update(harness.database.exercises)
          ..where((row) => row.id.equals(exercise.id)))
        .write(const ExercisesCompanion(einseitig: Value(false)));
    final fresh =
        await (harness.database.exercises.select()
              ..where((row) => row.id.equals(exercise.id)))
            .getSingle();
    final plan = await _planWith(harness.database, [fresh]);
    final hannoverWorkout = await harness.database.workouts.insertOne(
      WorkoutsCompanion.insert(
        planId: Value(plan.id),
        startedAt: DateTime(2026, 10, 10, 8),
        endedAt: Value(DateTime(2026, 10, 10, 9)),
      ),
    );
    final hamburgWorkout = await harness.database.workouts.insertOne(
      WorkoutsCompanion.insert(
        planId: Value(plan.id),
        startedAt: DateTime(2026, 10, 18, 8),
        endedAt: Value(DateTime(2026, 10, 18, 9)),
      ),
    );
    await insertExerciseSet(
      harness.database,
      exerciseId: fresh.id,
      workoutId: hannoverWorkout,
      exerciseSet: _view(
        fresh.name,
        5,
        100,
        DateTime(2026, 10, 10, 8, 5),
        notes: encodeSetNotes(gymId: 'hannover'),
      ),
    );
    await insertExerciseSet(
      harness.database,
      exerciseId: fresh.id,
      workoutId: hamburgWorkout,
      exerciseSet: _view(
        fresh.name,
        3,
        40,
        DateTime(2026, 10, 18, 8, 5),
        notes: encodeSetNotes(gymId: 'hamburg'),
      ),
    );
    alphaPrefs.gyms = [
      GymPlace(id: 'hannover', name: 'Hannover', lastUsedAt: DateTime.now()),
      GymPlace(
        id: 'hamburg',
        name: 'Hamburg',
        lastUsedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
    alphaPrefs.activeGymId = 'hamburg';
    await alphaPrefs.save();

    await _pushWorkout(tester, harness, plan, locale: const Locale('de'));
    for (
      var i = 0;
      i < 10 && find.text('Zuletzt: heute').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Wo trainierst du heute?'), findsOneWidget);
    expect(find.text('Zuletzt: heute'), findsOneWidget);
    expect(find.text('Zuletzt: vor 3 Tagen'), findsOneWidget);
    await _reveal(tester, find.byKey(const Key('gym-start-cancel')));
    await tester.tap(find.byKey(const Key('gym-start-cancel')));
    await tester.pumpAndSettle();
    final open =
        await (harness.database.workouts.select()
              ..where((row) => row.endedAt.isNull()))
            .get();
    expect(open, isEmpty);

    await tester.tap(find.text('open-workout'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    for (
      var i = 0;
      i < 10 && find.text('Zuletzt: heute').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.tap(find.byKey(const Key('gym-card-hamburg')));
    await tester.pump();
    await _reveal(tester, find.byKey(const Key('gym-start-confirm')));
    await tester.tap(find.byKey(const Key('gym-start-confirm')));
    await tester.pumpAndSettle();
    expect(find.text('40 kg × 3'), findsWidgets);
    expect(find.text('100 kg × 5'), findsNothing);
    expect(alphaPrefs.activeGymId, 'hamburg');

    final other = await harness.database.plans.insertReturning(
      PlansCompanion.insert(days: '', title: const Value('Other')),
    );
    await harness.database.planExercises.insertOne(
      PlanExercisesCompanion.insert(
        enabled: true,
        exerciseId: fresh.id,
        planId: other.id,
      ),
    );
    await harness.database.workouts.insertOne(
      WorkoutsCompanion.insert(
        planId: Value(other.id),
        startedAt: DateTime.now(),
      ),
    );
    await harness.pump(
      tester,
      GymWorkoutPage(plan: other),
      locale: const Locale('de'),
      surfaceSize: const Size(400, 900),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('gym-start-sheet')), findsNothing);
    expect(find.byKey(Key('set-reps-${fresh.id}-0')), findsOneWidget);
  });

  testWidgets('deleting a set removes it immediately', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    await _quietTimers(harness.database);
    await _resetGyms();
    final exercise = await _unilateral(harness.database, 'Cable row');
    await (harness.database.update(harness.database.exercises)
          ..where((row) => row.id.equals(exercise.id)))
        .write(const ExercisesCompanion(einseitig: Value(false)));
    final plan = await _planWith(harness.database, [exercise]);
    await harness.pump(
      tester,
      GymWorkoutPage(plan: plan),
      surfaceSize: const Size(400, 900),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(Key('set-kg-${exercise.id}-0')), '20');
    await tester.enterText(find.byKey(Key('set-reps-${exercise.id}-0')), '8');
    await tester.tap(find.byKey(Key('set-check-${exercise.id}-0')));
    await tester.pumpAndSettle();
    expect(await harness.database.exerciseSets.select().get(), hasLength(1));

    await tester.tap(find.byKey(Key('set-menu-${exercise.id}-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete set'));
    await tester.pumpAndSettle();

    expect(find.text('Undo'), findsNothing);
    expect(find.text('Set removed'), findsNothing);
    expect(find.text('Confirm Delete'), findsNothing);
    expect(await harness.database.exerciseSets.select().get(), isEmpty);
  });

  testWidgets('long press sorts exercise names and cancel keeps the order', (
    tester,
  ) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    await _quietTimers(harness.database);
    await _resetGyms();
    final names = ['Alpha Curl', 'Bravo Press', 'Charlie Row'];
    final exercises = [
      for (final name in names) await _unilateral(harness.database, name),
    ];
    for (final exercise in exercises) {
      await (harness.database.update(harness.database.exercises)
            ..where((row) => row.id.equals(exercise.id)))
          .write(const ExercisesCompanion(einseitig: Value(false)));
    }
    final plan = await _planWith(harness.database, exercises);
    await harness.pump(
      tester,
      GymWorkoutPage(plan: plan),
      surfaceSize: const Size(400, 900),
    );
    await tester.pumpAndSettle();
    final before = await _order(harness.database);

    await tester.longPress(
      find.byKey(Key('sort-exercise-${exercises.first.id}')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('workout-sort-sheet')), findsOneWidget);
    expect(find.text('Order'), findsOneWidget);
    for (final name in names) {
      expect(find.text(name), findsWidgets);
    }
    await tester.tap(find.byKey(const Key('workout-sort-cancel')));
    await tester.pumpAndSettle();
    expect(await _order(harness.database), before);

    await tester.longPress(
      find.byKey(Key('sort-exercise-${exercises.first.id}')),
    );
    await tester.pumpAndSettle();
    final handle = find.byKey(Key('sort-handle-${exercises.first.id}'));
    await tester.drag(handle, const Offset(0, 180));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('workout-sort-done')));
    await tester.pumpAndSettle();
    final after = await _order(harness.database);
    expect(after, isNot(before));
    expect(after.first, isNot(exercises.first.id));

    final many = [
      for (var i = 0; i < 12; i++)
        await _unilateral(harness.database, 'Move $i'),
    ];
    final longPlan = await _planWith(harness.database, many);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await harness.pump(
      tester,
      GymWorkoutPage(key: const Key('long-workout'), plan: longPlan),
      surfaceSize: const Size(400, 800),
    );
    await tester.pumpAndSettle();
    await tester.longPress(find.byKey(Key('sort-exercise-${many.first.id}')));
    await tester.pumpAndSettle();
    final sheet = tester.getSize(find.byKey(const Key('workout-sort-sheet')));
    expect(sheet.height, greaterThan(700));
  });
}

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isEmpty) continue;
    final rect = tester.getRect(finder);
    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    if (rect.top >= 0 &&
        rect.bottom <= size.height &&
        rect.left >= 0 &&
        rect.right <= size.width) {
      return;
    }
  }
}

Future<void> _pushWorkout(
  WidgetTester tester,
  FlexifyTestHarness harness,
  Plan plan, {
  Locale? locale,
}) async {
  await harness.pump(
    tester,
    Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => GymWorkoutPage(plan: plan),
              ),
            );
          },
          child: const Text('open-workout'),
        ),
      ),
    ),
    locale: locale,
    surfaceSize: const Size(400, 900),
  );
  await tester.tap(find.text('open-workout'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  for (
    var i = 0;
    i < 10 && find.byKey(const Key('gym-start-sheet')).evaluate().isEmpty;
    i++
  ) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _quietTimers(AppDatabase database) {
  return database.settings.update().write(
    const SettingsCompanion(restTimers: Value(false)),
  );
}

Future<void> _resetGyms() async {
  alphaPrefs.gyms = [GymPlace(id: 'default', name: 'Studio')];
  alphaPrefs.activeGymId = 'default';
  await alphaPrefs.save();
}

Future<Exercise> _unilateral(AppDatabase database, String name) {
  return database.exercises.insertReturning(
    ExercisesCompanion.insert(
      name: name,
      kind: 'strength',
      displayUnit: 'kg',
      einseitig: const Value(true),
    ),
  );
}

Future<Plan> _planWith(AppDatabase database, List<Exercise> exercises) async {
  final plan = await database.plans.insertReturning(
    PlansCompanion.insert(days: '', title: Value(exercises.first.name)),
  );
  for (var i = 0; i < exercises.length; i++) {
    await database.planExercises.insertOne(
      PlanExercisesCompanion.insert(
        enabled: true,
        exerciseId: exercises[i].id,
        planId: plan.id,
        sequence: Value(i),
      ),
    );
  }
  return plan;
}

Future<void> _side(
  AppDatabase database,
  Exercise exercise,
  int workoutId,
  DateTime at,
  String side,
  double reps, {
  double kg = 20,
}) {
  return insertExerciseSet(
    database,
    exerciseId: exercise.id,
    workoutId: workoutId,
    lookupBodyWeight: false,
    exerciseSet: _view(exercise.name, reps, kg, at, side: side),
  );
}

ExerciseSetView _view(
  String name,
  double reps,
  double kg,
  DateTime created, {
  String? side,
  String notes = '',
}) {
  return ExerciseSetView(
    id: 0,
    name: name,
    reps: reps,
    weight: kg,
    unit: 'kg',
    created: created,
    bodyWeight: 0,
    duration: 0,
    distance: 0,
    cardio: false,
    side: side,
    notes: notes,
  );
}

Future<List<int>> _order(AppDatabase database) async {
  final workout =
      await (database.workouts.select()..where((row) => row.endedAt.isNull()))
          .getSingle();
  return workout.exerciseOrder!.split(',').map(int.parse).toList();
}
