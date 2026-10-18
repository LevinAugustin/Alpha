import 'package:drift/drift.dart' hide Column, isNull, isNotNull;
import 'package:flexify/alpha/live_workout.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/import/import_export_page.dart';
import 'package:flexify/l10n/generated/app_localizations.dart';
import 'package:flexify/main.dart';
import 'package:flexify/shell/live_workout_bar.dart';
import 'package:flexify/shell/start_page.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flexify/workout/gym_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/test_app.dart';

void main() {
  tearDown(() {
    liveWorkout.value = null;
  });

  testWidgets('the live bar uses the root navigator', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    addTearDown(harness.timerState.stopTimer);
    final plan =
        await (harness.database.plans.select()
              ..where((row) => row.id.equals(2)))
            .getSingle();
    final workoutId = await harness.database.workouts.insertOne(
      WorkoutsCompanion.insert(
        planId: Value(plan.id),
        startedAt: DateTime.now(),
      ),
    );
    liveWorkout.value = LiveWorkout(
      planId: plan.id,
      workoutId: workoutId,
      title: 'Mittwoch',
      exercise: 'Kreuzheben',
    );
    final setting = await harness.database.settings.select().getSingle();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          StreamProvider<Setting>(
            initialData: setting,
            create: (_) => harness.database.watchSettings(),
          ),
          ChangeNotifierProvider.value(value: harness.timerState),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          theme: alphaThemeData(AlphaPalette.tiefschwarz),
          locale: const Locale('de'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            return Column(
              children: [
                Expanded(child: child ?? const SizedBox.shrink()),
                const LiveWorkoutBar(),
              ],
            );
          },
          home: const Scaffold(body: Text('home')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('live-workout-bar')));
    await tester.pumpAndSettle();
    expect(find.byType(GymWorkoutPage), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(liveWorkout.value?.workoutId, workoutId);

    await tester.tap(find.byKey(const Key('leave-workout')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('discard-live-workout')));
    await tester.pumpAndSettle();
    expect(find.text('Training verwerfen?'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Löschen'));
    await tester.pumpAndSettle();
    expect(liveWorkout.value, isNull);
    expect(await harness.database.workouts.select().get(), isEmpty);
  });

  testWidgets('start continues the running workout', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    addTearDown(harness.timerState.stopTimer);
    final plans =
        await (harness.database.plans.select()
              ..orderBy([(row) => OrderingTerm.asc(row.sequence)]))
            .get();
    final running = plans[1];
    final workoutId = await harness.database.workouts.insertOne(
      WorkoutsCompanion.insert(
        planId: Value(running.id),
        startedAt: DateTime.now(),
      ),
    );
    liveWorkout.value = LiveWorkout(
      planId: running.id,
      workoutId: workoutId,
      title: 'Mittwoch',
      exercise: 'Kreuzheben',
    );

    await harness.pump(
      tester,
      const StartPage(),
      locale: const Locale('de'),
      surfaceSize: const Size(400, 900),
    );
    await tester.pumpAndSettle();

    expect(find.text('Training fortsetzen'), findsOneWidget);
    expect(find.textContaining('Training starten'), findsNothing);

    await tester.tap(find.byKey(const Key('start-workout')));
    await tester.pumpAndSettle();

    expect(find.byType(GymWorkoutPage), findsOneWidget);
    expect(find.text('Mittwoch'), findsWidgets);
    final workouts = await harness.database.workouts.select().get();
    expect(workouts, hasLength(1));
    expect(workouts.single.id, workoutId);
    expect(workouts.single.planId, running.id);
    expect(workouts.single.endedAt, isNull);
  });

  testWidgets('data page offers a zip backup import', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    await harness.pump(
      tester,
      const ImportExportPage(),
      locale: const Locale('de'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sicherung importieren (.zip)'), findsOneWidget);
    expect(find.byKey(const Key('import-backup-zip')), findsOneWidget);
  });
}
