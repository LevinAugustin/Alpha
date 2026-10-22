import 'dart:io';

import 'package:drift/drift.dart' hide Column, isNull, isNotNull;
import 'package:flexify/alpha/alpha_prefs.dart';
import 'package:flexify/alpha/gym_start_sheet.dart';
import 'package:flexify/alpha/set_notes.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/database/exercise_set_repository.dart';
import 'package:flexify/l10n/generated/app_localizations.dart';
import 'package:flexify/main.dart';
import 'package:flexify/profile/local_profiles.dart';
import 'package:flexify/settings/alpha_settings_page.dart';
import 'package:flexify/storage/app_storage_native.dart';
import 'package:flexify/timer/timer_state.dart';
import 'package:flexify/workout/gym_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import 'support/test_app.dart';

void main() {
  test('the oldest studio owns sets that have no studio', () {
    final older = GymPlace(id: 'z', name: 'Alt', createdAt: DateTime.utc(2020));
    final newer = GymPlace(id: 'a', name: 'Neu', createdAt: DateTime.utc(2024));
    expect(firstStudio([newer, older])!.id, 'z');
    expect(
      firstStudio([
        GymPlace(id: '2000', name: 'Neu'),
        GymPlace(id: 'default', name: 'Studio'),
      ])!.id,
      'default',
    );
    expect(sameGym(null, 'default', firstGymId: 'default'), isTrue);
    expect(sameGym(null, 'a', firstGymId: 'default'), isFalse);
    expect(
      sameGym(encodeSetNotes(gymId: 'a'), 'a', firstGymId: 'default'),
      isTrue,
    );
    expect(
      sameGym(encodeSetNotes(gymId: 'a'), 'default', firstGymId: 'default'),
      isFalse,
    );
    expect(hasCreatedStudios(const []), isFalse);
  });

  test('untagged sets count only at the first studio', () async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    final exercise = await harness.database.exercises.insertReturning(
      ExercisesCompanion.insert(
        name: 'Row',
        kind: 'strength',
        displayUnit: 'kg',
      ),
    );
    final plan = await harness.database.plans.insertReturning(
      PlansCompanion.insert(days: '', title: const Value('Pull')),
    );
    final past = await harness.database.workouts.insertOne(
      WorkoutsCompanion.insert(
        planId: Value(plan.id),
        startedAt: DateTime(2026, 10, 1),
        endedAt: Value(DateTime(2026, 10, 1, 1)),
      ),
    );
    final untagged = await insertExerciseSet(
      harness.database,
      exerciseId: exercise.id,
      workoutId: past,
      exerciseSet: _set(exercise.name, 100, notes: null),
    );
    await insertExerciseSet(
      harness.database,
      exerciseId: exercise.id,
      workoutId: past,
      exerciseSet: _set(exercise.name, 40, notes: encodeSetNotes(gymId: 'b')),
    );
    final atFirst = await insertExerciseSet(
      harness.database,
      exerciseId: exercise.id,
      workoutId: past,
      exerciseSet: _set(exercise.name, 90, notes: encodeSetNotes(gymId: 'a')),
    );
    final atSecond = await insertExerciseSet(
      harness.database,
      exerciseId: exercise.id,
      workoutId: past,
      exerciseSet: _set(exercise.name, 50, notes: encodeSetNotes(gymId: 'b')),
    );

    expect(
      await isBestExerciseSet(
        harness.database,
        atFirst,
        gymId: 'a',
        firstGymId: 'a',
      ),
      isFalse,
    );
    expect(
      await isBestExerciseSet(
        harness.database,
        atSecond,
        gymId: 'b',
        firstGymId: 'a',
      ),
      isTrue,
    );
    final stored = await (harness.database.select(
      harness.database.exerciseSets,
    )..where((row) => row.id.equals(untagged.id))).getSingle();
    expect(stored.notes, isNull);
    expect(stored.loadKg, 100);
  });

  testWidgets('the first workout requires a studio name', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    addTearDown(_restoreStudio);
    await _quiet(harness.database);
    alphaPrefs.gyms = [];
    alphaPrefs.activeGymId = '';
    await alphaPrefs.save();
    final plan = await _plan(harness.database);

    await _open(tester, harness, plan);
    expect(find.byKey(const Key('first-studio-field')), findsOneWidget);
    expect(find.byKey(const Key('gym-start-without')), findsNothing);
    await tester.tap(find.byKey(const Key('first-studio-save')));
    await tester.pump();
    expect(find.byKey(const Key('first-studio-field')), findsOneWidget);
    expect(
      await (harness.database.workouts.select()
            ..where((row) => row.endedAt.isNull()))
          .get(),
      isEmpty,
    );

    await tester.enterText(find.byKey(const Key('first-studio-field')), 'Nord');
    await tester.tap(find.byKey(const Key('first-studio-save')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(alphaPrefs.gyms.single.name, 'Nord');
    expect(alphaPrefs.activeGymId, alphaPrefs.gyms.single.id);
    expect(find.byKey(const Key('finish-workout')), findsOneWidget);
  });

  testWidgets('two studios ask before the start and one does not', (
    tester,
  ) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    addTearDown(_restoreStudio);
    await _quiet(harness.database);
    final plan = await _plan(harness.database);
    alphaPrefs.gyms = [
      GymPlace(id: 'a', name: 'Alt', createdAt: DateTime.utc(2020)),
      GymPlace(id: 'b', name: 'Neu', createdAt: DateTime.utc(2024)),
    ];
    alphaPrefs.activeGymId = 'b';
    await alphaPrefs.save();

    await _open(tester, harness, plan);
    expect(find.byKey(const Key('gym-start-sheet')), findsOneWidget);
    expect(find.byKey(const Key('gym-add-studio')), findsOneWidget);
    expect(find.byKey(const Key('gym-start-without')), findsNothing);
    expect(
      await (harness.database.workouts.select()
            ..where((row) => row.endedAt.isNull()))
          .get(),
      isEmpty,
    );
  });

  testWidgets('old sets without a studio show up at the first studio', (
    tester,
  ) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    addTearDown(_restoreStudio);
    await _quiet(harness.database);
    final exercise = await harness.database.exercises.insertReturning(
      ExercisesCompanion.insert(
        name: 'Curl',
        kind: 'strength',
        displayUnit: 'kg',
      ),
    );
    final plan = await harness.database.plans.insertReturning(
      PlansCompanion.insert(days: '', title: const Value('Arms')),
    );
    await harness.database.planExercises.insertOne(
      PlanExercisesCompanion.insert(
        enabled: true,
        exerciseId: exercise.id,
        planId: plan.id,
        sequence: const Value(0),
      ),
    );
    final past = await harness.database.workouts.insertOne(
      WorkoutsCompanion.insert(
        planId: Value(plan.id),
        startedAt: DateTime(2026, 10, 1),
        endedAt: Value(DateTime(2026, 10, 1, 1)),
      ),
    );
    await insertExerciseSet(
      harness.database,
      exerciseId: exercise.id,
      workoutId: past,
      exerciseSet: _set(exercise.name, 100, reps: 5),
    );
    alphaPrefs.gyms = [
      GymPlace(id: 'a', name: 'Alt', createdAt: DateTime.utc(2020)),
    ];
    alphaPrefs.activeGymId = '';
    await alphaPrefs.save();

    await _open(tester, harness, plan);
    for (var i = 0; i < 20 && find.text('100 kg × 5').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('100 kg × 5'), findsOneWidget);
    final stored = await harness.database.exerciseSets.select().getSingle();
    expect(gymIdFromNotes(stored.notes), isNull);
  });

  testWidgets('profiles can be renamed and deleted without touching data', (
    tester,
  ) async {
    final support = await _profiles();
    addTearDown(() async {
      profileSupportDirectoryOverride = null;
      try {
        await db.close();
      } catch (_) {}
      if (support.existsSync()) support.deleteSync(recursive: true);
    });
    final adaPath = p.join(support.path, 'profile_p2.sqlite');
    await _pumpSettings(tester);

    expect(
      tester
          .widget<TextButton>(find.byKey(const Key('profile-delete-default')))
          .onPressed,
      isNull,
    );
    expect(find.textContaining('cannot be deleted'), findsOneWidget);
    expect(find.byKey(const Key('profile-switch-p2')), findsOneWidget);
    expect(find.byKey(const Key('profile-rename-p2')), findsOneWidget);

    await tester.tap(find.byKey(const Key('profile-rename-p2')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byKey(const Key('rename-profile-field')), '');
    await tester.tap(find.byKey(const Key('confirm-rename-profile')));
    await tester.pump();
    expect(find.text('The name cannot be empty.'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('rename-profile-field')),
      'levin',
    );
    await tester.tap(find.byKey(const Key('confirm-rename-profile')));
    await tester.pump();
    expect(find.text('That name is already used.'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('rename-profile-field')),
      'Bea',
    );
    await tester.tap(find.byKey(const Key('confirm-rename-profile')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final renamed = AppDatabase.forPath(adaPath);
    addTearDown(renamed.close);
    expect(
      (await renamed.plans.select().get()).map((plan) => plan.title),
      contains('Ada Plan'),
    );
    expect(
      (await (renamed.settings.select()..limit(1)).getSingle()).profileName,
      'Bea',
    );
    expect(find.text('Bea'), findsWidgets);

    await tester.tap(find.byKey(const Key('profile-delete-p2')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('confirm-delete-profile')))
          .onPressed,
      isNull,
    );
    await tester.enterText(
      find.byKey(const Key('delete-profile-field')),
      'Nope',
    );
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('confirm-delete-profile')))
          .onPressed,
      isNull,
    );
    await tester.enterText(
      find.byKey(const Key('delete-profile-field')),
      'Bea',
    );
    await tester.pump();
    final deleteButton = tester.widget<FilledButton>(
      find.byKey(const Key('confirm-delete-profile')),
    );
    expect(deleteButton.onPressed, isNotNull);
    expect(
      deleteButton.style?.backgroundColor?.resolve({}),
      const Color(0xFFB42318),
    );
    await renamed.close();
    await tester.tap(find.byKey(const Key('confirm-delete-profile')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(File(adaPath).existsSync(), isFalse);
    expect(find.text('Bea'), findsNothing);
    expect(
      (await db.plans.select().get()).map((plan) => plan.title),
      contains('Levin Plan'),
    );
    final registry = await loadProfileRegistry();
    expect(registry.profiles.map((profile) => profile.id), ['default']);
  });

  testWidgets('switching profiles shows that profile and clears a workout', (
    tester,
  ) async {
    final support = await _profiles();
    addTearDown(() async {
      profileSupportDirectoryOverride = null;
      try {
        await db.close();
      } catch (_) {}
      if (support.existsSync()) support.deleteSync(recursive: true);
    });
    final levinPath = p.join(support.path, databaseFileName);
    await db.workouts.insertOne(
      WorkoutsCompanion.insert(
        planId: Value(1),
        startedAt: DateTime(2026, 10, 20),
      ),
    );
    await _pumpSettings(tester);

    await tester.tap(find.byKey(const Key('profile-switch-p2')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('switch-workout-cancel')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      (await db.plans.select().get()).map((plan) => plan.title),
      contains('Levin Plan'),
    );
    expect(
      await (db.workouts.select()..where((row) => row.endedAt.isNull())).get(),
      isNotEmpty,
    );

    await tester.tap(find.byKey(const Key('profile-switch-p2')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('switch-workout-discard')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(
      (await db.plans.select().get()).map((plan) => plan.title),
      contains('Ada Plan'),
    );

    final levin = AppDatabase.forPath(levinPath);
    addTearDown(levin.close);
    expect(
      (await levin.plans.select().get()).map((plan) => plan.title),
      contains('Levin Plan'),
    );
    expect(
      await (levin.workouts.select()..where((row) => row.endedAt.isNull()))
          .get(),
      isEmpty,
    );
    final again = await openActiveProfile();
    addTearDown(again.close);
    expect(
      (await again.plans.select().get()).map((plan) => plan.title),
      contains('Ada Plan'),
    );
  });
}

ExerciseSetView _set(String name, double kg, {String? notes, double reps = 8}) {
  return ExerciseSetView(
    bodyWeight: 0,
    cardio: false,
    created: DateTime(2026, 10, 1, 8),
    distance: 0,
    duration: 0,
    id: 0,
    name: name,
    notes: notes,
    reps: reps,
    unit: 'kg',
    weight: kg,
  );
}

Future<void> _quiet(AppDatabase database) {
  return database.settings.update().write(
    const SettingsCompanion(restTimers: Value(false)),
  );
}

Future<void> _restoreStudio() async {
  alphaPrefs.gyms = [
    GymPlace(
      id: 'default',
      name: 'Studio',
      createdAt: DateTime.utc(2020, 1, 1),
    ),
  ];
  alphaPrefs.activeGymId = 'default';
  await alphaPrefs.save();
}

Future<Plan> _plan(AppDatabase database) async {
  final exercise = await database.exercises.insertReturning(
    ExercisesCompanion.insert(
      name: 'Press',
      kind: 'strength',
      displayUnit: 'kg',
    ),
  );
  final plan = await database.plans.insertReturning(
    PlansCompanion.insert(days: '', title: const Value('Push')),
  );
  await database.planExercises.insertOne(
    PlanExercisesCompanion.insert(
      enabled: true,
      exerciseId: exercise.id,
      planId: plan.id,
      sequence: const Value(0),
    ),
  );
  return plan;
}

Future<void> _open(
  WidgetTester tester,
  FlexifyTestHarness harness,
  Plan plan,
) async {
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
    locale: const Locale('en'),
    surfaceSize: const Size(400, 900),
  );
  await tester.tap(find.text('open-workout'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<Directory> _profiles() async {
  final support = Directory.systemTemp.createTempSync('alpha-profiles-');
  profileSupportDirectoryOverride = support;
  final levin = AppDatabase.forPath(p.join(support.path, databaseFileName));
  db = levin;
  await levin.settings.update().write(
    const SettingsCompanion(profileName: Value('Levin')),
  );
  await levin.plans.insertOne(
    PlansCompanion.insert(days: '', title: const Value('Levin Plan')),
  );
  final ada = AppDatabase.forPath(p.join(support.path, 'profile_p2.sqlite'));
  await ada.settings.update().write(
    const SettingsCompanion(profileName: Value('Ada')),
  );
  await ada.plans.insertOne(
    PlansCompanion.insert(days: '', title: const Value('Ada Plan')),
  );
  await ada.close();
  await saveProfileRegistry(
    ProfileRegistry(
      activeId: defaultProfileId,
      profiles: const [
        LocalProfile(
          id: defaultProfileId,
          name: 'Levin',
          fileName: databaseFileName,
        ),
        LocalProfile(id: 'p2', name: 'Ada', fileName: 'profile_p2.sqlite'),
      ],
      onboarded: true,
    ),
  );
  return support;
}

Future<void> _pumpSettings(WidgetTester tester) async {
  final setting = await (db.settings.select()..limit(1)).getSingle();
  await tester.pumpWidget(
    ValueListenableBuilder<int>(
      valueListenable: dbVersion,
      builder: (context, version, _) => MultiProvider(
        key: ValueKey(version),
        providers: [
          StreamProvider<Setting>(
            initialData: setting,
            create: (_) => db.watchSettings(),
          ),
          ChangeNotifierProvider(create: (_) => TimerState()),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AlphaSettingsPage(),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}
