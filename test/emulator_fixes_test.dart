import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flexify/alpha/live_workout.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/profile/local_profiles.dart';
import 'package:flexify/shell/start_page.dart';
import 'package:flexify/storage/app_storage_native.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flexify/workout/gym_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_app.dart';

void main() {
  tearDown(() {
    liveWorkout.value = null;
  });

  test(
    'fresh install enables rest timers without rewriting a saved choice',
    () async {
      final harness = await FlexifyTestHarness.create();
      addTearDown(harness.database.close);
      final fresh = await harness.database.settings.select().getSingle();
      expect(fresh.restTimers, isTrue);
      expect(fresh.enableSound, isTrue);

      await harness.database.settings.update().write(
        const SettingsCompanion(
          restTimers: Value(false),
          enableSound: Value(false),
        ),
      );
      final kept = await harness.database.settings.select().getSingle();
      expect(kept.restTimers, isFalse);
      expect(kept.enableSound, isFalse);
    },
  );

  testWidgets('back leaves the workout running', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    addTearDown(harness.timerState.stopTimer);
    final plan =
        await (harness.database.plans.select()
              ..where((row) => row.id.equals(1)))
            .getSingle();

    Future<void> open() async {
      await tester.tap(find.text('open-workout'));
      await tester.pumpAndSettle();
    }

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
      surfaceSize: const Size(400, 900),
    );

    await open();
    expect(liveWorkout.value?.planId, plan.id);
    final workoutId = liveWorkout.value!.workoutId;
    await tester.tap(find.byKey(const Key('leave-workout')));
    await tester.pumpAndSettle();
    expect(find.byType(GymWorkoutPage), findsNothing);
    expect(liveWorkout.value?.workoutId, workoutId);
    final parked =
        await (harness.database.workouts.select()
              ..where((row) => row.id.equals(workoutId)))
            .getSingle();
    expect(parked.endedAt, isNull);

    await open();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(GymWorkoutPage), findsNothing);
    expect(liveWorkout.value?.workoutId, workoutId);

    await open();
    await tester.tap(find.byKey(const Key('finish-workout')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-finish')));
    await tester.pumpAndSettle();
    expect(liveWorkout.value, isNull);
    final finished =
        await (harness.database.workouts.select()
              ..where((row) => row.id.equals(workoutId)))
            .getSingle();
    expect(finished.endedAt, isNotNull);
  });

  testWidgets('swapping an exercise updates the live bar name', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    addTearDown(harness.timerState.stopTimer);
    final plan =
        await (harness.database.plans.select()
              ..where((row) => row.id.equals(1)))
            .getSingle();
    final links =
        await (harness.database.planExercises.select()
              ..where((row) => row.planId.equals(plan.id))
              ..orderBy([(row) => OrderingTerm.asc(row.sequence)]))
            .get();
    final bench =
        await (harness.database.exercises.select()
              ..where((row) => row.id.equals(links.first.exerciseId)))
            .getSingle();
    final other =
        await (harness.database.exercises.select()
              ..where((row) => row.id.equals(links[1].exerciseId)))
            .getSingle();
    await harness.database.exercises.update().replace(
      bench.copyWith(germanName: const Value('Bankdrücken')),
    );
    await harness.database.exercises.update().replace(
      other.copyWith(germanName: const Value('Kniebeuge')),
    );

    await harness.pump(
      tester,
      GymWorkoutPage(plan: plan),
      locale: const Locale('de'),
      surfaceSize: const Size(400, 900),
    );
    await tester.pumpAndSettle();
    expect(liveWorkout.value?.exercise, 'Bankdrücken');

    await tester.tap(find.byKey(Key('exercise-menu-${bench.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Übung tauschen'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'Kniebeuge',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Kniebeuge'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-add-exercise')));
    await tester.pumpAndSettle();

    expect(liveWorkout.value?.exercise, 'Kniebeuge');
    expect(find.text('Kniebeuge'), findsWidgets);
  });

  testWidgets('checking a set starts the rest timer', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    addTearDown(harness.timerState.stopTimer);
    final settings = await harness.database.settings.select().getSingle();
    expect(settings.restTimers, isTrue);
    expect(settings.enableSound, isTrue);
    final plan =
        await (harness.database.plans.select()
              ..where((row) => row.id.equals(1)))
            .getSingle();
    final link =
        await (harness.database.planExercises.select()
              ..where((row) => row.planId.equals(plan.id))
              ..limit(1))
            .getSingle();
    await (harness.database.exercises.update()
          ..where((row) => row.id.equals(link.exerciseId)))
        .write(const ExercisesCompanion(defaultRestDurationMs: Value(210000)));

    await harness.pump(
      tester,
      GymWorkoutPage(plan: plan),
      surfaceSize: const Size(400, 900),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(Key('set-kg-${link.exerciseId}-0')),
      '40',
    );
    await tester.enterText(
      find.byKey(Key('set-reps-${link.exerciseId}-0')),
      '8',
    );
    await tester.tap(find.byKey(Key('set-check-${link.exerciseId}-0')));
    await tester.pump();

    expect(harness.timerState.timer.isRunning(), isTrue);
    expect(
      harness.timerState.timer.getRemaining().inSeconds,
      inInclusiveRange(200, 210),
    );
    await harness.timerState.stopTimer();
  });

  testWidgets(
    'home reloads after a workout, a tab return, and a profile save',
    (tester) async {
      final harness = await FlexifyTestHarness.create();
      addTearDown(harness.database.close);
      final active = ValueNotifier(true);
      addTearDown(active.dispose);
      final exercise = await (harness.database.exercises.select()..limit(1))
          .getSingle();

      await harness.pump(
        tester,
        StartPage(active: active),
        locale: const Locale('de'),
        surfaceSize: const Size(400, 900),
      );
      await tester.pumpAndSettle();
      expect(find.text('0 von 5', skipOffstage: false), findsOneWidget);

      await harness.database.exerciseSets.insertOne(
        ExerciseSetsCompanion.insert(
          exerciseId: exercise.id,
          timestamp: DateTime.now(),
          reps: const Value(8),
          loadKg: const Value(40),
        ),
      );
      liveWorkout.value = LiveWorkout(
        planId: 1,
        workoutId: 1,
        title: 'Montag',
        exercise: 'Bankdrücken',
      );
      liveWorkout.value = null;
      await tester.pumpAndSettle();
      expect(find.text('1 von 5', skipOffstage: false), findsOneWidget);
      expect(find.text('1 Tag in Folge', skipOffstage: false), findsOneWidget);
      expect(find.textContaining('Training starten'), findsOneWidget);

      await harness.database.delete(harness.database.exerciseSets).go();
      active.value = false;
      active.value = true;
      await tester.pumpAndSettle();
      expect(find.text('0 von 5', skipOffstage: false), findsOneWidget);

      await harness.database.exerciseSets.insertOne(
        ExerciseSetsCompanion.insert(
          exerciseId: exercise.id,
          timestamp: DateTime.now(),
          reps: const Value(5),
          loadKg: const Value(20),
        ),
      );
      await harness.database.settings.update().write(
        const SettingsCompanion(profileName: Value('Ada')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ada', skipOffstage: false), findsWidgets);
      expect(find.text('1 von 5', skipOffstage: false), findsOneWidget);
    },
  );

  testWidgets('home without a profile keeps the week and start locked', (
    tester,
  ) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    final active = ValueNotifier(true);
    addTearDown(active.dispose);
    await harness.pump(
      tester,
      StartPage(active: active),
      locale: const Locale('de'),
      surfaceSize: const Size(400, 900),
    );
    await tester.pumpAndSettle();
    await harness.database.settings.update().write(
      const SettingsCompanion(profileName: Value(null)),
    );
    await saveProfileRegistry(
      ProfileRegistry(
        activeId: defaultProfileId,
        profiles: const [
          LocalProfile(
            id: defaultProfileId,
            name: '',
            fileName: databaseFileName,
          ),
        ],
        onboarded: true,
      ),
    );
    active.value = false;
    active.value = true;
    await tester.pumpAndSettle();

    expect(find.text('Willkommen bei Alpha'), findsOneWidget);
    expect(find.text('Profil erstellen'), findsOneWidget);
    expect(find.text('Diese Woche'), findsOneWidget);
    expect(find.textContaining('Training starten'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.byType(GymWorkoutPage), findsNothing);
    final lock = tester.getRect(find.byIcon(Icons.lock_outline));
    expect(tester.getRect(find.text('Diese Woche')).overlaps(lock), isFalse);
    expect(
      tester.getRect(find.textContaining('Training starten')).overlaps(lock),
      isFalse,
    );
    final streaks = find.textContaining('Folge');
    for (var index = 0; index < streaks.evaluate().length; index++) {
      expect(tester.getRect(streaks.at(index)).overlaps(lock), isFalse);
    }

    await tester.tap(find.byKey(const Key('locked-home')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('onboarding-name')), findsOneWidget);
  });

  testWidgets('hero text stays clear of the figure in every theme', (
    tester,
  ) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    for (final palette in const [
      AlphaPalette.tiefschwarz,
      AlphaPalette.eisblau,
      AlphaPalette.pink,
    ]) {
      await harness.pump(
        tester,
        Theme(data: alphaThemeData(palette), child: const StartPage()),
        locale: const Locale('de'),
        textScaler: const TextScaler.linear(1.8),
        surfaceSize: const Size(360, 800),
      );
      await tester.pumpAndSettle();
      final figure = tester.getRect(find.byType(Image));
      for (final label in const ['Levin', 'Wochenziel']) {
        expect(
          tester.getRect(find.text(label)).overlaps(figure),
          isFalse,
          reason: '${palette.id} $label',
        );
      }
      expect(
        tester.getRect(find.textContaining('Einheiten')).overlaps(figure),
        isFalse,
        reason: palette.id,
      );
      expect(tester.takeException(), isNull);
    }
  });
}
